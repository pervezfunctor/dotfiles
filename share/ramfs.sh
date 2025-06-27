#!/bin/bash
set -euo pipefail

BACKUP_DIR="/var/local/ramdisk-backup"

echo "==> Setting up fstab entries..."
cat <<EOF >>/etc/fstab
# tmpfs mounts for RAM-backed dirs
tmpfs /tmp       tmpfs defaults,noatime,mode=1777,size=512M 0 0
tmpfs /var/tmp   tmpfs defaults,noatime,mode=1777,size=256M 0 0
tmpfs /var/log   tmpfs defaults,noatime,nosuid,mode=0755,size=100M 0 0
tmpfs /var/cache tmpfs defaults,noatime,mode=0755,size=256M 0 0
EOF

echo "==> Creating backup directory..."
mkdir -p "$BACKUP_DIR"

echo "==> Creating RAM init + restore script..."
cat <<'EOF' >/usr/local/bin/ramdisk-init.sh
#!/bin/bash
BACKUP_DIR="/var/local/ramdisk-backup"

# Restore from disk
[ -d "$BACKUP_DIR/log" ]    && cp -a "$BACKUP_DIR/log/."    /var/log/ || true
[ -d "$BACKUP_DIR/cache" ]  && cp -a "$BACKUP_DIR/cache/."  /var/cache/ || true

# Recreate structure
mkdir -p /var/log/{apt,private,journal,nginx,pve,lxc,containers,samba,systemd}
touch /var/log/{btmp,lastlog,wtmp,faillog}
chmod 600 /var/log/btmp
chown root:utmp /var/log/{wtmp,lastlog,faillog}
chmod 664 /var/log/{wtmp,lastlog,faillog}

mkdir -p /var/cache/apt/archives/partial
mkdir -p /var/cache/ldconfig
mkdir -p /var/cache/man
chmod 755 /var/cache
EOF

chmod +x /usr/local/bin/ramdisk-init.sh

echo "==> Creating RAM backup script..."
cat <<'EOF' >/usr/local/bin/ramdisk-backup.sh
#!/bin/bash
BACKUP_DIR="/var/local/ramdisk-backup"

mkdir -p "$BACKUP_DIR"

# Sync RAM dirs to disk
rsync -a --delete /var/log/   "$BACKUP_DIR/log/"
rsync -a --delete /var/cache/ "$BACKUP_DIR/cache/"
EOF

chmod +x /usr/local/bin/ramdisk-backup.sh

echo "==> Creating systemd service for RAM disk init..."
cat <<EOF >/etc/systemd/system/ramdisk-init.service
[Unit]
Description=Setup RAM-backed directories from backup
Before=rsyslog.service
ConditionPathIsMountPoint=/var/log

[Service]
Type=oneshot
ExecStart=/usr/local/bin/ramdisk-init.sh

[Install]
WantedBy=multi-user.target
EOF

echo "==> Creating systemd service for RAM backup on shutdown..."
cat <<EOF >/etc/systemd/system/ramdisk-backup.service
[Unit]
Description=Backup RAM-backed directories to disk before shutdown
DefaultDependencies=no
Before=umount.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/ramdisk-backup.sh
RemainAfterExit=true

[Install]
WantedBy=halt.target reboot.target poweroff.target
EOF

echo "==> Enabling systemd services..."
systemctl daemon-reexec
systemctl enable ramdisk-init.service
systemctl enable ramdisk-backup.service

echo "==> All done. Reboot to apply tmpfs mounts and test!"
