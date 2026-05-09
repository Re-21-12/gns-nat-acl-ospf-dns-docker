hostname R4
ipv6 unicast-routing

interface Serial0/0
 description R4-R3
 ip address 10.0.34.2 255.255.255.252
 ipv6 address fd00:34::2/64
 ipv6 enable
 ip access-group ACL_R4_IN in
 ipv6 ospf 1 area 0
 no shutdown

interface Serial0/1
 description R4-R2
 ip address 10.0.24.2 255.255.255.252
 ipv6 address fd00:24::2/64
 ipv6 enable
 ip access-group ACL_R4_IN in
 ipv6 ospf 1 area 0
 no shutdown

interface FastEthernet0/0
 description LAN2
 ip address 10.2.0.1 255.255.255.0
 ipv6 address fd00:2::1/64
 ipv6 enable
 ip access-group ACL_LAN2_OUT out
 ipv6 ospf 1 area 0
 no shutdown

router ospf 1
 router-id 4.4.4.4
 network 10.0.24.0 0.0.0.3 area 0
 network 10.0.34.0 0.0.0.3 area 0
 network 10.2.0.0  0.0.0.255 area 0
 passive-interface FastEthernet0/0

ipv6 router ospf 1
 router-id 4.4.4.4

ip access-list extended ACL_R4_IN
 permit ospf any any
 permit udp host 10.0.12.1 eq 53 10.2.0.0 0.0.0.255
 permit udp any host 10.0.12.1 eq 53
 permit tcp any host 10.0.12.1 eq 80
 permit tcp any any established
 permit icmp any any
 deny ip any any log

ip access-list extended ACL_LAN2_OUT
 permit udp any host 10.0.12.1 eq 53
 permit udp host 10.0.12.1 eq 53 10.2.0.0 0.0.0.255
 permit tcp any host 10.0.12.1 eq 80
 permit tcp 10.2.0.0 0.0.0.255 any eq 80
 permit ospf any any
 permit tcp any any established
 permit icmp any any
 deny ip any any log