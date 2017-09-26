***Linux для начинающих***

root
xertam123

benkinew
verty123


//////////////
man [command] #help 
shift UP|DOWN

reboot
shutdown -n now #off server


systemctl -p /etc/sysctl.conf

////DIRECTORY/////
pwd #local dir
ls (-l) [/dir/] #contents dir #1
ll [/dir] #contents dir #2
du -hsx [/dir/] #size dir

cd [/dir]
mkdir [/dir] #creat dir
cp [file] [/dir/]  #copy files
	cp -r [/dir/] [/dir] #copy dir
rm [file] #del files (y/n)
touch [file] #new files
mv [file] [/dir/] (if new name [/dir/][new files name]) #move files
********************************
vi [file]
	a #input text {INSERT}
	Esc
	:wq #write and exit files
*******************************
cat [file] #all text files

find [/dir] -name [file] #search files

tail [file] #contents inside files 10 last line
	tail -20 [file] #last 20 line
head [file] #contents inside files 10 first line
	head -20 [file] #first 20 line

grep [text] [file] #search text in file
	tail -40 [file] | grep [text] #contents 40 line in files and search text
	tail -40 [file] | grep [text] | head -2 #contents 40 line in files and search text AND 2 line first
*************************************
//SYSTEM INFO///
df -h #HDD
top #Tasts/CPU/Memory/Swap
	q #exit

ps aux #Processes
	ps aux | grep [proc] #find proc
	kiil №proc #delete procc


///LAN///
linux: ssh IP -l users	#ex. ssh 192.168.2.241 -l benkinew

/etc/sysconfig/network-scripts/ #LAN config
	ifcfg-[name] #lan interface enp0s3
	ifcfg-lo

vi ifcfg-enp0s3 #edit lan
#lan addres 192.168.2.0
#mask 255.255.255.0 /24
#IP addres 192.168.2.230
#IP router 192.168.2.1
	
[root@localhost ~]# cat /etc/sysconfig/network-scripts/ifcfg-enp0s3 
		TYPE=Ethernet
		BOOTPROTO=static
		IPADDR=192.168.2.230
		NETWORK=192.168.2.0
		NETMASK=255.255.255.0
		GATEWAY=192.168.2.1
		NAME=enp0s3
		UUID=1f407e3d-1c8f-467f-8088-034393ff5f34
		DEVICE=enp0s3
		ONBOOT=yes
		#NM_CONTROLLED="no"
		PROXY_METHOD=none
		BROWSER_ONLY=no
		PREFIX=24
		DNS1=8.8.8.8
		DEFROUTE=yes
		IPV4_FAILURE_FATAL=no
		IPV6INIT=no



service network restart [OK]

vi /etc/resolv.conf #edit DNS
	search [name] #local 
	nameserver 192.168.2.1 #IP router

	
nmcli d #connect lan

	
***************************************************************
///USERS///

useradd #new users
passwd #user pass

visudo -f /etc/sudoers #add users to root privilege
## Allow root to run any commands anywhere
root    ALL=(ALL)       ALL
[users] ALL=(ALL) ALL

///SSH no root///
	benkinew@srv:/root$ vi /etc/ssh/sshd_config 
	benkinew@srv:/root$ sudo vi /etc/ssh/sshd_config 

	Мы полагаем, что ваш системный администратор изложил вам основы
	безопасности. Как правило, всё сводится к трём следующим правилам:

		№1) Уважайте частную жизнь других.
		№2) Думайте, прежде что-то вводить.
		№3) С большой властью приходит большая ответственность.

	[sudo] пароль для benkinew: 

	
# Authentication:
PermitRootLogin no


///////access rights/////

chown [users]:[group] [/dir/] #edit access 
	chown -R [users]:[group] [/dir/] #edit access all element
	
chmod [access lvl] [/dir/] #edit access lvl

//////////YUM pacets///////////////

/etc/yum.conf #yum config
/etc/yum.peros.d/ # yum perositor

yum install -y #install pacets
				nano
				mc
				net-tools #ifconfig
				bind-utils #nslookup
				telnet
				NetworkManager-tui #nmtui
				
yum provides [pacets] # pacets
yum search [all] [name] #search pacets name


//////////////SEGMENTS [FIREWALL]/////////
lan adress
	DMZ - 192.168.250.0/24
	SERVERS - 192.168.251.0/24
	USERS - 192.168.252.0/24

addresses of network gateway interfaces
	DMZ - 192.168.250.1
	SERVERS - 192.168.251.1
	USERS - 192.168.252.1

Adapter name
	enp0s8	dmz #2
	enp0s9	srv #3
	enp0s10	user #4
	

nmcli c add type [ethernet] con-name [enp0s8] ifname [enp0s8] ip4 [192.168.250.1/24] #add interface
nmcli device connect [enp0s8] #ON interface

///////////IPTABLES///////////
    systemctl stop firewalld
    systemctl disable firewalld
    reboot


iptables -L -v -n #rools 

yum install iptables-services #yum pacets iptables

/etc/sysctl.conf #машрутизацыя трафика
	net.ipv4.ip_forward = 1

iptables -A[конец цепочки] INPUT[сама цепочка] -i lo[интерефейс] -j ACCEPT[дествия правила] #весь входящий и исходящий трафик для lo
iptables -A OUTPUT -o lo -j ACCEPT 

iptables -A OUTPUT -o [enp0s3] -j ACCEPT #входящий инет
iptables -A INPUT -p icmp[протокол] -j ACCEPT #пинг на сервер
iptables -A OUTPUT -p icmp[протокол] -j ACCEPT #пинг ис сервер
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED [состояния] -j ACCEPT #правила для соединений
iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED [состояния] -j ACCEPT 

iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp --dport 22 -j ACCEPT #SSH

iptables -P INPUT DROP #запретить
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

ping [windows comp] #задать входящие разрешения по ICMP в windows брандмауэре
telnet [addres] 80 #доступ к inet

iptables -t nat -A POSTROUTING -o [enp0s3] -s [192.168.252.0/24] -j MASQUERADE #users zone - адрес источника подменить адрес сервера

iptables -A FORWARD -p icmp -j ACCEPT # трафик по всем интерфейсам
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED [состояния] -j ACCEPT

iptables -A FORWARD -s [192.168.252.0/24] -p tcp -m conntrack --ctstate NEW -m multiport --dports [80,443] -j ACCEPT # доступ к http(s)
iptables -A FORWARD -p tcp -m conntrack --ctstate NEW -m tcp --dport 53 -j ACCEPT #access DNS
iptables -A FORWARD -p udp -m conntrack --ctstate NEW -m udp --dport 53 -j ACCEPT


iptables-save > /etc/sysconfig/iptables #save iptables ruls

systemctl enable iptables #вкл iptables

////////////reset IPTABLES///////////root@srv:~# iptables -P INPUT ACCEPT
root@srv:~# iptables -P FORWARD ACCEPT
root@srv:~# iptables -P OUTPUT ACCEPT
root@srv:~# iptables -t nat -F
root@srv:~# iptables -t mangle -F
root@srv:~# iptables -F
root@srv:~# iptables -X
root@srv:~# iptables -L -v -n

//////////////////////////////////
  288  iptables -A INPUT -i lo -j ACCEPT
  289  iptables -A OUTPUT -o lo -j ACCEPT
  290  iptables -A OUTPUT -o enp0s3 -j ACCEPT
  291  iptables -A INPUT -p icmp -j ACCEP
  292  iptables -A INPUT -p icmp -j ACCEPT
  293  iptables -A OUTPUT -p icmp -j ACCEPT
  294  iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 
  295  iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 
  296  iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp --dport 22 -j ACCEPT 
  297  iptables -P INPUT DROP
  298  iptables -P OUTPUT DROP
  299  iptables -P FORWARD DROP
  300  iptables -t nat -A POSTROUTING -o enp0s3 -s 192.168.252.0/24 -j MASQUERADE 
  301  iptables -A FORWARD -p icmp -j ACCEPT 
  302  iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
  303  iptables -A FORWARD -s 192.168.252.0/24 -p tcp -m conntrack --ctstate NEW -m multiport --dports 80,443 -j ACCEPT
  304  iptables -A FORWARD -p tcp -m conntrack --ctstate NEW -m tcp --dport 53 -j ACCEPT
  305  iptables -A FORWARD -p udp -m conntrack --ctstate NEW -m udp --dport 53 -j ACCEPT
  306  iptables-save > /etc/sysconfig/iptables
  307  systemctl enable iptables
  308  systemctl status iptables
  309  iptables -L -v -n

  
  
  ////////////DHCP//////////////
nmcli general hostname [name] #edit hostname - srv.local
nmcli c mod [enp0s3] ipv4.dns [192.168.2.1] #add dns server
systemctl restart network #restart network

/etc/dhcp/dhcpd.conf #config dchp
cp [example] /etc/dhcp/dhcpd.conf #copy conf

# option definitions common to all supported networks...
option domain-name "[local]"; #host
option domain-name-servers [192.168.2.1],[ip/name dns]; #dns

# User sabnet conf - 192.168.252.0/24
subnet 192.168.252.0 netmask 255.255.255.0 {
  range 192.168.252.5 192.168.252.254;
  option domain-name-servers 192.168.2.1;
  option domain-name "local";
  option routers 192.168.252.1;
  option broadcast-address 192.168.252.255;
  default-lease-time 691200;
  max-lease-time 691200;
}


# - all text

systemctl enable dhcpd
systemctl start dchpd

cat /var/lib/dhcpd/dhcpd.leases #info dhcp client

/etc/rsyslog.conf #edit log

	# Save log DHCP 
local7.*                                                /var/log/dhcpd.log

systemctl restart rsyslog
systemctl restart dhcpd
cat /var/log/dhcpd.log








  
  
  


 






	
	
	
	
	
	
	
	
	
	
	
	
	