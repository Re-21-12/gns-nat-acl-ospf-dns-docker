! ── Hostname ─────────────────────────────────────────────
hostname R1

! ── IPv6 global ──────────────────────────────────────────
ipv6 unicast-routing

! ── Interfaces ───────────────────────────────────────────
interface FastEthernet0/0
 description LAN1
 ip address 10.1.0.1 255.255.255.0
 ipv6 address fd00:1::1/64
 ipv6 enable
 ip nat inside
 ipv6 ospf 1 area 0
 no shutdown

interface Serial0/0
 description R1-R2
 ip address 10.0.12.1 255.255.255.252
 ipv6 address fd00:12::1/64
 ipv6 enable
 ip nat outside
 ip access-group ACL_WAN_IN in
 ip access-group ACL_WAN_OUT out
 clock rate 64000
 ipv6 ospf 1 area 0
 no shutdown

interface Serial0/1
 description R1-R3
 ip address 10.0.13.1 255.255.255.252
 ipv6 address fd00:13::1/64
 ipv6 enable
 ip nat outside
 ip access-group ACL_WAN_IN in
 ip access-group ACL_WAN_OUT out
 clock rate 64000
 ipv6 ospf 1 area 0
 no shutdown

! ── OSPFv2 ───────────────────────────────────────────────
router ospf 1
 router-id 1.1.1.1
 network 10.0.12.0 0.0.0.3 area 0
 network 10.0.13.0 0.0.0.3 area 0
 network 10.1.0.0  0.0.0.255 area 0
 passive-interface FastEthernet0/0

! ── OSPFv3 ───────────────────────────────────────────────
ipv6 router ospf 1
 router-id 1.1.1.1

! ── NAT estatico ─────────────────────────────────────────
ip nat inside source static tcp 10.1.0.11 80  10.0.12.1 80
ip nat inside source static tcp 10.1.0.10 53  10.0.12.1 53
ip nat inside source static udp 10.1.0.10 53  10.0.12.1 53

! ── PAT (overload) ───────────────────────────────────────
ip nat inside source list NAT_LAN1 interface Serial0/0 overload
ip access-list standard NAT_LAN1
 permit 10.1.0.0 0.0.0.255

! ── NAT timeout ──────────────────────────────────────────
ip nat translation udp-timeout 30
ip nat translation timeout 300

! ── ACL_WAN_IN (inbound S0/0 y S0/1) ────────────────────
ip access-list extended ACL_WAN_IN
 5  permit tcp host 10.1.0.11 eq 80 10.2.0.0 0.0.0.255
 6  permit tcp host 10.1.0.10 eq 53 10.2.0.0 0.0.0.255
 7  permit udp host 10.1.0.10 eq 53 10.2.0.0 0.0.0.255
 10 permit ospf any any
 20 permit udp any host 10.0.12.1 eq 53
 30 permit tcp any host 10.0.12.1 eq 53
 40 permit udp any eq 53 any
 50 permit tcp any host 10.0.12.1 eq 80
 60 permit icmp any any
 70 deny ip any any log

! ── ACL_WAN_OUT (outbound S0/0 y S0/1) ──────────────────
ip access-list extended ACL_WAN_OUT
 5  permit tcp host 10.1.0.11 eq 80 10.2.0.0 0.0.0.255
 6  permit tcp host 10.1.0.10 eq 53 10.2.0.0 0.0.0.255
 7  permit udp host 10.1.0.10 eq 53 10.2.0.0 0.0.0.255
 10 permit udp any eq 53 10.2.0.0 0.0.0.255
 20 permit tcp any eq 53 10.2.0.0 0.0.0.255
 30 permit tcp any eq 80 10.2.0.0 0.0.0.255
 40 permit ospf any any
 50 permit icmp any any
 60 permit tcp any any established
 70 permit ip 10.1.0.0 0.0.0.255 any
 80 deny ip any any log