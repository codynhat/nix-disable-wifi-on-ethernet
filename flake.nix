{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    packages.${system} = {
      default = pkgs.writeShellScriptBin "disable-wifi-on-ethernet" ''
        #!/bin/bash
        
        ETHERNET_DEVICE='en7\|en9'
        
        NETWORKSETUP=/usr/sbin/networksetup
        IFCONFIG=/sbin/ifconfig
        
        WiFi=$($NETWORKSETUP -listallhardwareports | grep -A1 "Wi-Fi" | grep Device | cut -f2 -d' ')
        
        echo "Run $0"
        echo "Wifi interface $WiFi"
        echo "Ethernet interface $ETHERNET_DEVICE"
        
        EthernetStatus=$($IFCONFIG | grep -A7 $ETHERNET_DEVICE | grep status | cut -f2 -d' ')
        echo "Ethernet is currently $EthernetStatus"
        
        if [ "$EthernetStatus" != "active" ]; 
        then 
            $NETWORKSETUP -setairportpower $WiFi on
            echo "Wi-Fi set on"
        else
            $NETWORKSETUP -setairportpower $WiFi off
            echo "Wi-Fi set off"
        fi
      '';
    };
  };
}