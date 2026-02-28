#! /usr/bin/env nu

# Generate default libvirt network XML with random UUID and MAC

use ./share/utils.nu *

# Generate random MAC address in libvirt format
export def generate-mac []: nothing -> string {
    let bytes = (seq 1 3 | each { random int 0..255 })
    let bytes_str = ($bytes | each { |b| $b | fmt | get lower | str substring 0..2 })
    $"52:54:00:($bytes_str | str join ':')"
}

# Main command
export def main [] {
    let uuid = (random uuid)
    let mac = (generate-mac)
    let tmp_file = "/tmp/default.xml"

    let xml_content = $"<network>
  <name>default</name>
  <uuid>($uuid)</uuid>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='($mac)'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
"

    $xml_content | save -f $tmp_file
    info $"Generated network XML at ($tmp_file)"

    # Define and start the network
    sudo virsh net-define $tmp_file
    sudo virsh net-autostart default
    sudo virsh net-start default

    success "Default libvirt network created and started"
}

