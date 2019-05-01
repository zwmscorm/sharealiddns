大
1、这是一个全功能的ALIDDNS脚本，支持IPV4和IPV6，具体看说明文档router/myscripts/sharealiddns/readme/readme.txt。
2、此脚本来是放在koolshare论坛上，被管理员不小心屏蔽，考虑再三，决定还是放在这安全。
======================================================================================
使用本脚本前声明：
1、你必须到阿里云进行域名实名认证。
2、域名信息必须在阿里云中成功通过审核。
3、阿里云给你的key和cret，必须是正确而有效的。
4、以上3点是必须的，少一个条件都不可以，否则你是不可能从阿里云获取到域名解析记录的，更不用说添加或更新记录了。
5、你要有一个公网IPV4 IP地址(有IPV6 IP环境除外)。
======================================================================================
脚本功能说明：
1、本脚本是从我的软路由上(ubuntu 16.04搭建的路由器环境)剥离出来，并按梅林系统重新修改而成。
2、本脚本就是脚本，不是插件，没有设置界面，只给有一定脚本基础的网友使用，记住：越强的路由越是没有设置界面。
3、本脚本实际上是通过阿里云提供的API对解析记录进行增加，更新，删除，验证等操作，所以从这个意义上说它还不是一个插件。
4、本脚本有增加，更新，删除，验证解析记录等功能（这句是多余的，可以不看）。
5、网友不要偿试给这个脚本增加设置界面，不要在nvram增加保存参数，不要在dbus保存什么参数，否则本脚本会运行不稳定，原因不解释，
    写这个脚本初心就是保证它是纯绿色无公害而稳定。
======================================================================================
解析记录冲突规则说明:https://help.aliyun.com/knowledge_detail/39787.html
使用本脚本前学习一下对你有好处。 
======================================================================================
如何在WINDOWS COMMAND行中测试域名解析是否成功，假设你的域名是www.abc.com：
1、刷新终端dns缓存：
   windows commind:ipconfig/flushdns
2、测试权威dns服务器是否已经正确解析：
   windows commind:nslookup www.abc.com
3、查看AAAA记录：
   windows commind:nslookup -qt=aaaa www.abc.com
4、查看A记录：
   windows commind:nslookup -qt=a www.abc.com
5、获取dns解析服务器：
   windows commind:nslookup -qt=ns aliyun.com
======================================================================================
私有概念定义：  
1、光猫桥接，与之相联的路由用来拨号，则是一级路由，接在一级路由之后的为二级路由。
2、光猫拨号，则光猫为一级路由，联在光猫之后的路由是二级路由。
3、你可直接理解成：拨号的东东就是一级路由，其它是二级路由，三级路由...。
4、如果你用光猫拨号，就必须在光猫进行端口转发设置，行吗？ 估计很难，所以在二级路由上运行本脚本也没有实际意义。
======================================================================================
配置文件account.conf中的pppoe_ifname参数设置：
1、对于二级路由（是路由），pppoe_ifname必须设置为any。
2、对于一级路由（是光猫非路由），pppoe_ifname必须也只能设置为any。
3、对于一级路由（非光猫是路由），接入的是单线，则pppoe_ifname设置为wan0或auto，最好设置为auto。
4、对于一级路由（非光猫是路由），接入的是双线，取wan0公网IP，则pppoe_ifname设置为wan0，取wan1公网IP，则pppoe_ifname设置为wan1。
5、对于一级路由（非光猫是路由），采用多拨模式，我没有环境，所以没办法测试。
6、对于有多台路由环境，选择其中一台路由运行此脚本就可以，不可多台都运行此脚本，否则域名解析有可能发生冲突。
======================================================================================
配置文件account.conf中的islog参数设置：
islog设置为1时开启脚本运行日志，设置为0时关闭脚本运行日志，日志文件在log目录内。
======================================================================================
配置文件account.conf中定时更新域名时间参数设置：
    cron_Time_type:时间类型，可以设置为min或hour。
    cron_Time:当cron_Time_type设置为min时，可设置值为5~59，cron_Time_type设置为hour时，可设置为1~23。
    IPV6由于还在测试阶段，不太稳定，建议cron_Time_type设置为min，cron_Time设置在10~30。
======================================================================================
配置文件account.conf中的isipv4_domain和isipv6_domain参数设置：
    isipv4_domain设置为1，执行IPV4域名解析，设置为0，不执行IPV4域名解析。
	isipv6_domain设置为1，执行IPV6域名解析，设置为0，不执行IPV6域名解析。
======================================================================================
配置文件account.conf域名参数设置：
注意：
    1、无公网IPV4 IP但有IPV6 IP，只设置IPV6条目，所有和IPV4相关的条目要全部删除。
    2、有公网IPV4 IP但无IPV6 IP，只设置IPV4条目，所有和IPV6相关的条目要全部删除。
    3、有公网IPV4 IP且有IPV6 IP，IPV4条目和IPV6条目都要设置。

具体设置说明：
    1、aliddns_AccessKeyId和aliddns_AccessKeySecret，阿里给你的key和cret，不知是哪个，下面就不用看啦。
    2、routerddns_no，在有多个域名的情况下，用哪一个域名远程访问路由器。
    3、aliddns_name为主机别名，支持直通符@, 通配符*或具体的别名(如www, sss, yyy, m等)，不能设置为空值。
	4、aliddns_domain，为主机域名，如abc.com。
    5、aliddns_ttl，为解析有效生存时间，设置600。
    6、aliddns_type，为记录类型，IPV4，必须设置为A，IPV6，必须设置为AAAA。
	7、aliddns_lan_mac，给接在路由器后端的终端设备(NAS、PC等),提供域名解析，这个功能是专门为IPV6设置的，需要将终端设备
	    的MAC地址设置给aliddns_lan_mac，可能会出现IPV6 IP已经改变而不能即时更新阿里上的记录，原因是固件的DHCP6问题，所以，
		最好保证终端设备一直处于活跃状态。如果运营商封端口，此功能可能会失效。

有多个域名IPV4例子：
    #1_aliddns_domain#
    aliddns_name=@
    aliddns_domain=abc.com
    aliddns_ttl=600
    aliddns_type=A
	aliddns_lan_mac=
   
    #2_aliddns_domain#
    aliddns_name=www
    aliddns_domain=abc.com
    aliddns_ttl=600
    aliddns_type=A
	aliddns_lan_mac=
   
    #3_aliddns_domain#
    aliddns_name=m
    aliddns_domain=abc.com
    aliddns_ttl=600
    aliddns_type=A
	aliddns_lan_mac=
   
    #4_aliddns_domain#
    aliddns_name=yyy
    aliddns_domain=abc.com
    aliddns_ttl=600
    aliddns_type=A
	aliddns_lan_mac=
   
有多个域名IPV4和IPV6的例子：
    #1_aliddns_domain#
    aliddns_name=*
    aliddns_domain=abc.com
    aliddns_ttl=600
    aliddns_type=A
	aliddns_lan_mac=
   
    #2_aliddns_domain#
    aliddns_name=@
    aliddns_domain=abc.com
    aliddns_ttl=600
    aliddns_type=A
	aliddns_lan_mac=
	
	#3_aliddns_domain#
    aliddns_name=*
    aliddns_domain=abc.com
    aliddns_ttl=600
    aliddns_type=AAAA
	aliddns_lan_mac=
   
    #4_aliddns_domain#
    aliddns_name=@
    aliddns_domain=abc.com
    aliddns_ttl=600
    aliddns_type=AAAA
	aliddns_lan_mac=

给终端设备提供IPV6域名解析的例子(aliddns_name必须有一个具体的值，如nas，home，两个终端设备网卡MAC假设是
    33:D7:7A:2B:DE:6B和65:D0:7B:2A:DE:4A)：
    #1_aliddns_domain#
    aliddns_name=*
    aliddns_domain=abc.com
    aliddns_ttl=600
    aliddns_type=AAAA
   
    #2_aliddns_domain#
    aliddns_name=@
    aliddns_domain=abc.com
    aliddns_ttl=600
    aliddns_type=AAAA
	
	#3_aliddns_domain#
    aliddns_name=nas
    aliddns_domain=abc.com
    aliddns_ttl=600
    aliddns_type=AAAA
	aliddns_lan_mac=33:D7:7A:2B:DE:6B
   
    #4_aliddns_domain#
    aliddns_name=home
    aliddns_domain=abc.com
    aliddns_ttl=600
    aliddns_type=AAAA
	aliddns_lan_mac=65:D0:7B:2A:DE:4A
	
远程访问：
    终端1: http://nas.abc.com
	终端2: http://home.abc.com
如果域名解析已经成功，但终端设备还是无法访问，你需要在windows command下运行：
    ipconfig/flushdns
win操作系统对IPV6支持还不完善。
======================================================================================
======================================================================================
安装方法：
    准备好winscp和xshell工具软件，或国产FinalShell免费版：
	1、运行winscp，将myscripts目录上传到JFFS，将/jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh提权到0755。
       如果想安装到U盘，可以将myscripts目录上传到U盘内，但U盘的分区标签要设置一个具体的值(比如myplugins)，此时脚本
       的绝对路径是/tmp/mnt/myplugins/myscripts/sharealiddns/etc/init.d/aliddns.sh，如果U盘的分区标签不设置为一
       个具体的值，则脚本的绝对路径可能是/tmp/mnt/sda1/sharealiddns/etc/init.d/aliddns.sh，重启路由
       后可能是/tmp/mnt/sdc1/sharealiddns/etc/init.d/aliddns.sh，你如何定位脚本并运行之。不会？按第1点做好了。
    2、打开/jffs/myscripts/sharealiddns/conf/account.conf，按remdme.txt上的说明填好你自己的域名信息。
    3、打开xshell，运行:
       sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh restart
	   如果是安装到U盘的myplugins分区：
	   sh /tmp/mnt/myplugins/myscripts/sharealiddns/etc/init.d/aliddns.sh restart
	   安装就算完成了。
======================================================================================
    脚本一些功能调用：
    检测account.conf所有域名是否成功解析：
        sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh check
		或
		sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh check 0
    检测account.conf第3个域名是否成功解析：
        sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh check 3
    增加或更新account.conf所有域名:
        sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh restart	
		或 
		sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh restart 0
    增加或更新account.conf第3个域名:
        sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh restart 3
    删除account.conf所有域名:
        sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh remove 0
		或
		sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh removeall
    删除account.conf第3域名:
        sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh remove 3
    设置account.conf第3域名解析记录为禁用
        sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh status 3 0
    设置account.conf第3域名解析记录为启用
        sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh status 3 1
	设置account.conf所有域名解析记录为启用
        sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh status 0 1
	设置account.conf所有域名解析记录为禁用
        sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh status 0 0
    对account.conf所有域名进行兼容性和压力测试(开发模式专用)：
        sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh monitor
    对account.conf第3域名进行兼容性和压力测试(开发模式专用)：
        sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh monitor 3
	对account.conf所有域名进行兼容性和压力测试(开发模式专用)：
        sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh monitor
	检测客户端状态：
	    sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh client ipv4
		或
		sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh client ipv6
	检测公网IP：
	    sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh checkwanip
	显示日志：
	    sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh showlog
======================================================================================
pc客户端IPV6权限问题：
1、检测IPV6
    netsh interface ipv6 set teredo client teredo.remlab.net. 60 34567
    netsh interface Teredo show state
    ping 240c::6666
    ping 240c::6644
2、上不了IPV6网站：
    netsh advfirewall set currentprofile firewallpolicy blockinbound,allowoutbound
3、设置 Teredo 服务器，默认为：win10.ipv6.microsoft.com   
   netsh interface teredo set state enterpriseclient server=default
4、卸载当前Teredo 适配器再重新启用  
   netsh interface Teredo set state disable  
   netsh interface Teredo set state type=default
5、重置 IPv6 配置 
    netsh interface ipv6 reset
6、测试网站：
   test-ipv6.com
   ipv6-test.com
   ipv6.cau.edu.cn
开启pc客户端IPV6:
1、gpedit.msc设置：
    打开"计算机配置" - "管理模板" - "网络" - "TCPIP 设置" - "IPv6 转换技术" ，
    "6to4 状态" 和 "ISATAP 状态" 都配置为 "已禁用状态"，
    "Teredo 状态" 配置为 "企业客户端"，"Teredo 默认限定" 配置为 "已启用状态"
2、如问题没解决？到下面下载相关工具：
    https://support.microsoft.com/en-us/help/929852/guidance-for-configuring-ipv6-in-windows-for-advanced-users
    下载Prefer IPv4 over IPv6 in prefix policies和Prefer IPv6 over IPv4 in prefix policies两个工具
3、运行regedit
   在HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\
   删除Tcpip6和TCPIP6TUNNEL
   安装上面两个工具
   重新启动电脑
4、设置IPV4比IPV6更优先： 
   netsh interface ipv6 set prefixpolicy ::ffff:0:0/96 100 4
   显示设置结果
   netsh interface ipv6 show prefixpolicies
======================================================================================
======================================================================================






