#!/bin/bash

# Author: Nisrin Ahmed aka Wh1teDrvg0n

# Función para verificar si iptables está instalado
check_iptables_installed() {
    if command -v iptables >/dev/null 2>&1; then
        echo "iptables ya está instalado."
        exit 0
    fi
}

# Función para instalar iptables en sistemas basados en Debian
install_iptables_debian() {
    sudo apt-get update
    sudo apt-get install -y iptables
}

# Función para instalar iptables en sistemas basados en Red Hat
install_iptables_redhat() {
    sudo yum install -y iptables
}

# Verificar si iptables ya está instalado
check_iptables_installed

# Detectar el sistema operativo y llamar a la función de instalación correspondiente
if [ -f /etc/debian_version ]; then
    echo "Sistema basado en Debian detectado."
    install_iptables_debian
elif [ -f /etc/redhat-release ]; then
    echo "Sistema basado en Red Hat detectado."
    install_iptables_redhat
else
    echo "Sistema operativo no soportado."
    exit 1
fi

echo "iptables se ha instalado correctamente."

  # IPv4 flush
  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -P OUTPUT ACCEPT
  iptables -t nat -F
  iptables -t mangle -F
  iptables -F
  iptables -X
  iptables -Z

  # IPv6 flush
  ip6tables -P INPUT DROP
  ip6tables -P FORWARD DROP
  ip6tables -P OUTPUT DROP
  ip6tables -t nat -F
  ip6tables -t mangle -F
  ip6tables -F
  ip6tables -X
  ip6tables -Z

  # Ping machine
  iptables -A INPUT -p icmp -i tun0 -s $1 --icmp-type echo-request -j ACCEPT
  iptables -A INPUT -p icmp -i tun0 -s $1 --icmp-type echo-reply -j ACCEPT
  iptables -A INPUT -p icmp -i tun0 --icmp-type echo-request -j DROP  
  iptables -A INPUT -p icmp -i tun0 --icmp-type echo-reply -j DROP
  iptables -A OUTPUT -p icmp -o tun0 -d $1 --icmp-type echo-reply -j ACCEPT
  iptables -A OUTPUT -p icmp -o tun0 -d $1 --icmp-type echo-request -j ACCEPT
  iptables -A OUTPUT -p icmp -o tun0 --icmp-type echo-request -j DROP
  iptables -A OUTPUT -p icmp -o tun0 --icmp-type echo-reply -j DROP

  # Allow VPN connection only from machine
  iptables -A INPUT -i tun0 -p tcp -s $1 -j ACCEPT
  iptables -A OUTPUT -o tun0 -p tcp -d $1 -j ACCEPT
  iptables -A INPUT -i tun0 -p udp -s $1 -j ACCEPT
  iptables -A OUTPUT -o tun0 -p udp -d $1 -j ACCEPT
  iptables -A INPUT -i tun0 -j DROP
  iptables -A OUTPUT -o tun0 -j DROP
  
