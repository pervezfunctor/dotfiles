# Define the WSL commands to be run
$wslCommands = @"
sudo apt install openssh-server
echo PasswordAuthentication yes/g >> /etc/ssh/sshd_config
echo Port 22 >> /etc/ssh/sshd_config
sudo service ssh restart

# Fix VS Code permissions issue
mkdir -p /tmp
sudo chmod 1777 /tmp
touch /tmp/remote-wsl-loc.txt
chmod 666 /tmp/remote-wsl-loc.txt
"@

# Run the WSL commands
wsl $wslCommands

# Get the IP address of the Windows host
$windows_host_ip = (Test-Connection -ComputerName (hostname) -Count 1).IPV4Address.IPAddressToString

# Get the IP address of the WSL
$wsl_internal_ip = wsl hostname -I

# Add the portproxy
netsh interface portproxy add v4tov4 `
  listenaddress=$windows_host_ip `
  listenport=2222 `
  connectaddress=$wsl_internal_ip `
  connectport=22

# Add the firewall rule
netsh advfirewall firewall add rule `
  name="wsl-ssh" `
  dir=in `
  action=allow `
  protocol=TCP `
  localport=2222
