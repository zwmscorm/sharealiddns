# 脚本说明文档   
　　**sharealiddns脚本是共享的，你可自由下载和使用，但不得用于商业目的，不得转载抄袭，以保证脚本代码的完整性。本脚本当初是放在国内的K&S论坛上方便大家下载和使用，但经常习惯性地被K&S屏蔽，这就不符合共享精神了，所以决定放在全球知名的开源github社区上托管共大家下载和使用。个人看来，K&S后面的S可以删除了，你觉
得呢？**
## 脚本使用条件：  
　　**1、安装asuswrt-merlin官方固件的路由器或安装以asuswrt-merlin源码编译的第三方固件路由器。     
       　　2、安装padavan固件的路由器。       
       　　3、安装pandorabox固件的路由器。     
       　　4、安装lede/openwrt固件的路由器。     
       　　5、你必须到阿里云进行域名实名认证。     
       　　6、域名信息必须在阿里云中成功通过审核。     
       　　7、阿里云给你的key和cret，必须是正确而有效的。     
       　　8、你要有一个公网IPV4 IP并独占(有IPV6 IP环境除外)。**       
 ## 脚本功能说明：    
　　**1、本脚本有批量增加，批量更新，批量删除，批量验证解析记录等功能。     
       　　2、本脚本支持N个域名解析。     
       　　3、主机别名支持直通符@, 通配符*或具体的别名。     
       　　4、本脚本支持IPV4和IPV6域名解析。     
       　　5、不支持中文域名。     
       　　6、更多功能只有使用中才发现。**   
         
 ## 重要提示：    
　　**如果你要进行IPV6域名解析，首先确认运营商已经推送IPV6，其次确保路由器固件支持IPV6并已开启IPV6功能，检查是否已经成功获得IPV6 IP，
  否则必须关闭IPV6，如何关闭IPV6？可以在路由器界面上进行设置，比如pandorabox、lede/openwrt固件的路由器需在网络-接口--WAN--高级设置
  --Obtain IPv6-Address Disabled--禁用。或者打开/etc/config/network文件，按下面设置：  
option  ipv6  '0'  
重启，使设置生效。**   
  # [更多说明请点击此处参看脚本说明文档readme.txt](https://github.com/zwmscorm/sharealiddns/blob/master/myscripts/sharealiddns/readme/readme.txt)       
  ## 安装方法：         
　　**1、准备好winscp和xshell工具软件，如国产FinalShell免费版软件。            
       　　2、要求固件的wget必须支持https，如不支持，必须升级，否则无法从github下载脚本和运行本脚本。      
       　　　  对pandorabox、lede/openwrt固件，可能还要安装https协议所需的软件包，在xshell或FinalShell     
       　　　  命令行窗口中粘贴下面安装软件包指令：     
       　　　  `opkg update && opkg install wget openssl-util libustream-openssl`     
       　　　  如只安装或升级wget，则粘贴下面的指令：  
       　　　  `opkg update && opkg install wget`  
       　　　  耐心等待直至安装完成。     
       　　3、拷贝下面的安装脚本指令并粘贴到xshell或FinalShell命令行窗口中，回车：   
---------------------------------------------------分割线下是安装脚本指令--------------------------------------------------------  
`cd /tmp/ && wget --no-check-certificate https://raw.githubusercontent.com/zwmscorm/sharealiddns/master/myscripts/sharealiddns-install.sh -O /tmp/sharealiddns-install.sh && sh /tmp/sharealiddns-install.sh`    
---------------------------------------------------分割线上是安装脚本指令--------------------------------------------------------  
如果固件有curl, 也可以用curl下载脚本:  
---------------------------------------------------分割线下是安装脚本指令--------------------------------------------------------  
`cd /tmp/ && curl -k https://raw.githubusercontent.com/zwmscorm/sharealiddns/master/myscripts/sharealiddns-install.sh -o /tmp/sharealiddns-install.sh && sh /tmp/sharealiddns-install.sh`    
---------------------------------------------------分割线上是安装脚本指令--------------------------------------------------------  
　　如果wget和curl都无法下载，可以先将sharealiddns-install.sh单独以web方式下载到本地，用winscp上传到路由器的tmp目录，然后将
            sharealiddns-install.sh权限提到0755, 在xshell或FinalShell命令行窗口中粘贴下面安装脚本指令：  
            `sh /tmp/sharealiddns-install.sh`  
            接着按提示进行操作：     
       　　4、将脚本安装到nand，则输入nand，将脚本安装到usb，则输入usb，删除脚本，则输入uninstall。     
       　　5、接着是设置aliddns.conf参数，请按readme.txt文档中的说明认真填写。     
       　　6、稍候脚本会自动运行，请注意观察脚本运行情况。如出现错误，会有提示。     
       　　　  如果aliddns.conf参数设置错误，请运行下面的指令(假设脚本安装到asuswrt-merlin固件nand的jffs)重新设置参数：     
       　　　  `sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh setconf`    
       　　　  或者使用winscp直接进入/jffs/myscripts/sharealiddns/conf目录对aliddns.conf进行修改。     
       　　　  大部分情况都是参数设置不正确，使得脚本运行出现错误。     
       　　　  至此，脚本已经安装完毕。     
       　　　  一行指令就完成了脚本的安装工作，是不是很简单!     
       　　7、如脚本安装到asuswrt-merlin固件的nand，则脚本的的路径是：      
       　　　  `/jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh`           
       　　8、如脚本安装到padavan固件的nand，则脚本的的路径是：      
       　　　  `/etc/storage/myscripts/sharealiddns/etc/init.d/sharealiddns.sh`           
       　　9、如脚本安装到pandorabox、lede/openwrt固件的的nand，则脚本的的路径是：           
       　　　  `/etc/myscripts/sharealiddns/etc/init.d/sharealiddns.sh`  
       　　10、如脚本安装到各固件的usb，则脚本的的路径视具体的情况而定。**   
     
   ## 部分运行脚本指令(假设脚本安装到asuswrt-merlin固件的nand):  
　　**1、设置aliddns.conf参数：     
       　　　  `sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh setconf `     
       　　2，增加或更新所有域名：     
       　　　  `sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh restart`     
       　　3，检测所有域名是否成功解析：     
       　　　  `sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh check`     
       　　4、删除所有域名:     
       　　　  `sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh remove 0`     
       　　5、监控域名解析：     
       　　　  `sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh monitor`     
       　　6、检测公网IPV4 IP或公网IPV6 IP：     
       　　　  `sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh checkwanip`     
       　　7、检测IPV4客户端状态：     
       　　　  `sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh client ipv4`     
       　　8、检测IPV6客户端状态：     
       　　　  `sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh client ipv6`**    

  ## [更多指令参看说明文档readme.txt](https://github.com/zwmscorm/sharealiddns/blob/master/myscripts/sharealiddns/readme/readme.txt)  
            
  ### [使用中有问题请issues](https://github.com/zwmscorm/sharealiddns/issues): https://github.com/zwmscorm/sharealiddns/issues
------------------------------------------------------------------------------------------------------------------------------------ 
       　　       　　       　　       　　       　2019.06.02 zwmscorm 

