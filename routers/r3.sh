hostname R3
ipv6 unicast-routing

interface Serial0/0
 description R3-R4
 ip address 10.0.34.1 255.255.255.252
 ipv6 address fd00:34::1/64
 ipv6 enable
 ip access-group ACL_R3_IN in
 ipv6 ospf 1 area 0
 no shutdown

interface Serial0/1
 description R3-R1
 ip address 10.0.13.2 255.255.255.252
 ipv6 address fd00:13::2/64
 ipv6 enable
 ip access-group ACL_R3_IN in
 ipv6 ospf 1 area 0
 no shutdown

router ospf 1
 router-id 3.3.3.3
 network 10.0.13.0 0.0.0.3 area 0
 network 10.0.34.0 0.0.0.3 area 0

ipv6 router ospf 1
 router-id 3.3.3.3

ip access-list extended ACL_R3_IN
 permit ospf any any
 permit icmp any any
 permit tcp any any established
 permit udp any eq 53 10.2.0.0 0.0.0.255
 permit tcp any eq 53 10.2.0.0 0.0.0.255
 permit tcp any eq 80 10.2.0.0 0.0.0.255
 permit ip 10.1.0.0 0.0.0.255 10.2.0.0 0.0.0.255
 permit ip 10.2.0.0 0.0.0.255 10.1.0.0 0.0.0.255
 deny ip any any log