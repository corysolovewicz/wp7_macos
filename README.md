# wp7 macOS
# 🍍 WiFi Pineapple Internet Sharing on macOS (with VPN Support)

## ❌ The Problem

By default, macOS Internet Connection Sharing (ICS):

- **Only shares internet on the `192.168.2.0/24` subnet**
- **Cannot be configured** to use custom subnets via the GUI
- **Assigns IPs via DHCP**, which does not work with the WiFi Pineapple MK7's default static IP configuration
- **Breaks compatibility** with the Pineapple’s expected interface at `172.16.42.1/24`

When using a VPN, macOS:

- Does **not** route shared traffic through the VPN by default  
- Lacks a built-in way to **NAT traffic from a USB interface to a VPN tunnel**  
- Provides **no direct way to ensure Pineapple traffic is tunneled securely**

This creates friction and reliability issues for red teamers, wireless assessors, or anyone trying to route Pineapple traffic through a VPN on macOS.

---

## ✅ The Solution: This Script

This shell script sets up secure Internet Connection Sharing (ICS) from your Mac to the WiFi Pineapple MK7 **while preserving the default `172.16.42.0/24` subnet** — and routes all traffic through your active VPN connection.

### 🔧 What the Script Does

1. **Detects the Pineapple's interface** by MAC address prefix `00:13:37`
2. **Assigns a static IP** of `172.16.42.42` to your Mac on that interface
3. **Enables IP forwarding** on macOS
4. **Detects your default outbound interface** (e.g., `utun0`, `ipsec0`) — typically the VPN tunnel
5. **Configures NAT** using `pfctl` to route traffic from the Pineapple’s subnet through the detected VPN interface
6. **Provides a menu interface** to start/stop ICS with optional banners
7. **Enforces VPN routing** by default, with a user prompt override for non-tunnel interfaces

---

## 🛡️ Why It Matters

- Ensures that **WiFi Pineapple clients access the internet via your VPN**
- Prevents traffic leakage by requiring or confirming a tunnel interface is in use
- Eliminates the need to reconfigure the Pineapple from its standard network layout
- Avoids modifying macOS’s ICS GUI settings or launching a DHCP server

---

## 💻 Usage

```
chmod +x wp7_macos.sh 
sudo ./wp7_macos.sh
```

You’ll be presented with a menu to:

- Start Internet Connection Sharing  
- Stop / undo all changes  
- Quit

---

## 🎯 When to Use

- During wireless red teaming or penetration tests  
- When using the WiFi Pineapple MK7 as a rogue AP or MITM relay  
- On macOS systems that must route traffic through a VPN  
- When you want clean setup/teardown without rebooting or manual configuration

---

## 📦 Requirements

- macOS (tested on Monterey, Ventura, Sonoma, Sequoia)  
- Any VPN that creates a tunnel interface (`utunX`, `ipsecX`)  
- WiFi Pineapple MK7 (default config)  
- Admin/root privileges

---

## 🚨 Revert Instructions

To fully undo changes:

- Run the script and choose `[X] Stop / Undo ICS]`  
- This will:
  - Disable IP forwarding  
  - Remove the static IP from the Pineapple interface  
  - Flush and disable `pfctl`  
  - Clean up `/etc/pf.anchors/com.pineapple.nat`

---

For more info, visit [https://hak5.org](https://hak5.org)
