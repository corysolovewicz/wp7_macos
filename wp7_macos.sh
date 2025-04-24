#!/bin/bash

# WiFi Pineapple MK7 - macOS ICS + VPN Routing Script
# Author: Cøry Solovewicz
# Contact: contact[at]cory[dot]so
# Usage:
# chmod +x wp7_macos.sh 
# sudo ./wp7_macos.sh
wpver=7.0

PINEAPPLE_SUBNET="172.16.42.0/24"
PINEAPPLE_HOST_IP="172.16.42.42"
NETMASK="255.255.255.0"
PF_ANCHOR="/etc/pf.anchors/com.pineapple.nat"
PF_CONF="/etc/pf.conf"

function banner {
    b=$(( ( RANDOM % 5 ) + 1 ))
    case "$b" in
        1)
        echo $(tput setaf 3)
        echo "    _       ___ _______    ____  _                              __    ";
        echo "   | |     / (_) ____(_)  / __ \\(_)___  ___  ____ _____  ____  / /__ ";
        echo "   | | /| / / / /_  / /  / /_/ / / __ \/ _ \/ __ '/ __ \/ __ \/ / _ \\";
        echo "   | |/ |/ / / __/ / /  / ____/ / / / /  __/ /_/ / /_/ / /_/ / /  __/ ";
        echo "   |__/|__/_/_/   /_/  /_/   /_/_/ /_/\___/\__,_/ .___/ .___/_/\___/  ";
        echo "                                               $(tput setaf 3)/_/   /_/$(tput sgr0)v$wpver";
        ;;
        2)
        echo $(tput setaf 3)
        echo "           ___       __          ___       __   __        ___ ";
        echo "   |  | | |__  |    |__) | |\ | |__   /\  |__) |__) |    |__  ";
        echo "   |/\| | |    |    |    | | \| |___ /~~\ |    |    |___ |___ ";
        echo "                                                       $(tput sgr0)v$wpver"
        ;;
        3)
        echo $(tput setaf 3)
        echo "  ▄▄▌ ▐ ▄▌▪  ·▄▄▄▪       ▄▄▄·▪   ▐ ▄ ▄▄▄ . ▄▄▄·  ▄▄▄· ▄▄▄·▄▄▌  ▄▄▄ .";
        echo "  ██· █▌▐███ ▐▄▄·██     ▐█ ▄███ •█▌▐█▀▄.▀·▐█ ▀█ ▐█ ▄█▐█ ▄███•  ▀▄.▀·";
        echo "  ██▪▐█▐▐▌▐█·██▪ ▐█·     ██▀·▐█·▐█▐▐▌▐▀▀▪▄▄█▀▀█  ██▀· ██▀·██▪  ▐▀▀▪▄";
        echo "  ▐█▌██▐█▌▐█▌██▌.▐█▌    ▐█▪·•▐█▌██▐█▌▐█▄▄▌▐█ ▪▐▌▐█▪·•▐█▪·•▐█▌▐▌▐█▄▄▌";
        echo "   ▀▀▀▀ ▀▪▀▀▀▀▀▀ ▀▀▀    .▀   ▀▀▀▀▀ █▪ ▀▀▀  ▀  ▀ .▀   .▀   .▀▀▀  ▀▀▀ ";
        echo "                                                               $(tput sgr0)v$wpver"
        ;;
        4)
        echo $(tput setaf 3)
        echo "  ▄ ▄   ▄█ ▄████  ▄█    █ ▄▄  ▄█    ▄   ▄███▄   ██   █ ▄▄  █ ▄▄  █     ▄███▄ ";
        echo " █   █  ██ █▀   ▀ ██    █   █ ██     █  █▀   ▀  █ █  █   █ █   █ █     █▀   ▀";
        echo "█ ▄   █ ██ █▀▀    ██    █▀▀▀  ██ ██   █ ██▄▄    █▄▄█ █▀▀▀  █▀▀▀  █     ██▄▄  ";
        echo "█  █  █ ▐█ █      ▐█    █     ▐█ █ █  █ █▄   ▄▀ █  █ █     █     ███▄  █▄   ▄";
        echo " █ █ █   ▐  █      ▐     █     ▐ █  █ █ ▀███▀      █  █     █        ▀ ▀███▀ ";
        echo "  ▀ ▀        ▀            ▀      █   ██           █    ▀     ▀         $(tput sgr0)v$wpver";
        ;;
        5)
        echo $(tput setaf 3)
        echo "               (          (                                                 ";
        echo " (  (          )\ )       )\ )                                     (        ";
        echo " )\))(   ' (  (()/(  (   (()/( (            (     )                )\   (   ";
        echo "((_)()\ )  )\  /(_)) )\   /(_)))\   (      ))\ ( /(  \`  )   \` )  ((_) ))\ ";
        echo "_(())\_)()((_)(_))_|((_) (_)) ((_)  )\ )  /((_))(_)) /(/(   /(/(   _  /((_) ";
        echo "\ \((_)/ / (_)| |_   (_) | _ \ (_) _(_/( (_)) ((_)_ ((_)_\ ((_)_\ | |(_))   ";
        echo " \ \/\/ /  | || __|  | | |  _/ | || ' \))/ -_)/ _\`|| '_ \)| '_ \)| |/ -_)  ";
        echo "  \_/\_/   |_||_|    |_| |_|   |_||_||_| \___|\__,_|| .__/ | .__/ |_|\___|  ";
        echo "                                                    |_|    |_|       $(tput sgr0)v$wpver";
        ;;
    esac
}

function description {
  echo "====================================================="
  echo "    WiFi Pineapple ICS + VPN (macOS only)            "
  echo "====================================================="
}

function detect_pineapple_interface {
  ifconfig | awk '
    /^[a-z]/ { iface=$1 }
    /ether 00:13:37/ { print iface }' | tr -d ':'
}

function detect_vpn_interface {
  route get 1.1.1.1 2>/dev/null | awk '/interface:/ {print $2}'
}

function start_ics {
  echo "[*] Detecting Pineapple interface by MAC (OUI 00:13:37)..."
  PINEAPPLE_IF=$(detect_pineapple_interface)
  if [[ -z "$PINEAPPLE_IF" ]]; then
    echo "[!] Could not detect Pineapple interface. Is it plugged in?"
    return
  fi
  echo "[+] Pineapple interface: $PINEAPPLE_IF"

  echo "[*] Finding network service for Pineapple interface..."
  PINEAPPLE_SERVICE=$(networksetup -listnetworkserviceorder | \
    grep -B1 "Device: $PINEAPPLE_IF" | head -1 | sed -E 's/^.*\) (.*)$/\1/')

  if [[ -z "$PINEAPPLE_SERVICE" ]]; then
    echo "[!] Could not find network service name for $PINEAPPLE_IF"
    return
  fi
  echo "[+] Pineapple service name: '$PINEAPPLE_SERVICE'"

  echo "[*] Configuring static IP for $PINEAPPLE_SERVICE..."
  sudo networksetup -setmanual "$PINEAPPLE_SERVICE" 172.16.42.42 255.255.255.0 172.16.42.1
  sudo networksetup -setdnsservers "$PINEAPPLE_SERVICE" 172.16.42.1

  echo "[*] Reordering network services (placing '$PINEAPPLE_SERVICE' last)..."

  ALL_SERVICES=()
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == "An asterisk (*) denotes that a network service is disabled." ]] && continue
    SERVICE_NAME=$(echo "$line" | sed 's/^\* //')
    ALL_SERVICES+=("$SERVICE_NAME")
  done < <(networksetup -listallnetworkservices)

  SERVICE_FOUND=0
  REORDERED_SERVICES=()
  for svc in "${ALL_SERVICES[@]}"; do
    if [[ "$svc" == "$PINEAPPLE_SERVICE" ]]; then
      SERVICE_FOUND=1
      continue
    fi
    REORDERED_SERVICES+=("\"$svc\"")
  done

  if [[ "$SERVICE_FOUND" -eq 0 ]]; then
    echo "[!] '$PINEAPPLE_SERVICE' not found in service list. Skipping reorder."
  else
    REORDERED_SERVICES+=("\"$PINEAPPLE_SERVICE\"")
    ORDER_CMD="sudo networksetup -ordernetworkservices ${REORDERED_SERVICES[*]}"
    echo "[*] Executing: $ORDER_CMD"
    if eval "$ORDER_CMD"; then
      echo "[+] Network services reordered successfully."
      echo "[*] Waiting for routing to update..."
      sleep 5
    else
      echo "[!] Failed to reorder network services. Check service names manually."
    fi
  fi

  echo "[*] Detecting VPN interface from default route..."
  VPN_IF=$(detect_vpn_interface)
  if [[ -z "$VPN_IF" ]]; then
    echo "[!] Could not detect VPN interface. Is VPN connected?"
    return
  fi
  echo "[+] Detected uplink interface: $VPN_IF"

  # VPN enforcement with override
  if ! [[ "$VPN_IF" =~ ^(utun|ipsec) ]]; then
    echo "[!] Warning: Uplink interface is not a tunnel (VPN is likely not active)."
    echo "    Detected interface: $VPN_IF"
    read -rp "    Continue anyway? [y/N]: " override
    override=$(echo "$override" | tr '[:upper:]' '[:lower:]')
    if [[ "$override" != "y" ]]; then
      echo "[x] Aborting ICS setup."
      return
    fi
  fi

  echo "[*] Enabling IP forwarding..."
  sudo sysctl -w net.inet.ip.forwarding=1

  echo "[*] Assigning static IP $PINEAPPLE_HOST_IP to $PINEAPPLE_IF (interface)..."
  sudo ifconfig "$PINEAPPLE_IF" inet "$PINEAPPLE_HOST_IP" netmask "$NETMASK" up

  echo "[*] Writing PF NAT rules..."
  sudo tee "$PF_ANCHOR" > /dev/null <<EOF
nat on $VPN_IF from $PINEAPPLE_SUBNET to any -> ($VPN_IF)
EOF

  sudo tee "$PF_CONF" > /dev/null <<EOF
scrub-anchor "com.pineapple.nat"
nat-anchor "com.pineapple.nat"
load anchor "com.pineapple.nat" from "$PF_ANCHOR"
EOF

  echo "[*] Loading PF config..."
  sudo pfctl -f "$PF_CONF"
  sudo pfctl -e

  echo "[✔] Routing is set up!"
  echo "    Pineapple interface: $PINEAPPLE_IF"
  echo "    Outbound Interface:  $VPN_IF"
  echo "    Subnet:              $PINEAPPLE_SUBNET"
  echo "    Set Pineapple's gateway to: $PINEAPPLE_HOST_IP"
}

function stop_ics {
  echo "[*] Reverting ICS setup..."
  echo "[*] Disabling IP forwarding..."
  sudo sysctl -w net.inet.ip.forwarding=0

  echo "[*] Detecting Pineapple interface..."
  PINEAPPLE_IF=$(detect_pineapple_interface)
  if [[ -n "$PINEAPPLE_IF" ]]; then
    echo "[*] Removing IP from $PINEAPPLE_IF..."
    sudo ifconfig "$PINEAPPLE_IF" inet 0.0.0.0 remove
  fi

  echo "[*] Disabling Packet Filter and removing rules..."
  sudo pfctl -F all
  sudo pfctl -d

  echo "[*] Removing custom NAT config and restoring default PF configuration..."
  sudo rm -f "$PF_ANCHOR"
  sudo cp /etc/pf.conf.default "$PF_CONF" 2>/dev/null || echo "scrub in all" | sudo tee "$PF_CONF"


  echo "[✔] ICS has been disabled."
}

function show_menu {
  banner
  echo
  description
  echo
  echo "  [S] Start Internet Connection Sharing"
  echo "  [X] Stop / Undo ICS"
  echo "  [Q] Quit"
  echo
  read -rp "Select an option: " choice
  choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
  case "$choice" in
    s) start_ics ;;
    x) stop_ics ;;
    q) echo "Exiting."; exit 0 ;;
    *) echo "Invalid option."; show_menu ;;
  esac
}

# Entry
show_menu
