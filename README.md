# sharealiddns脚本说明文档：
**sharealiddns脚本是共享的，你可自由下载和使用，但不得用于商业目的，引用时请注明来源。本脚本当初是放在国内
的K&S论坛上方便大家下载和使用，但经常习惯性地被K&S屏蔽，这就不符合共享精神了，所以决定放在全球知名的开源
github社区上托管共大家下载和使用。个人看来，K&S后面的S可以删除了，你觉得呢？**  

**脚本使用条件(所有安装asuswrt-merlin固件的路由器)：**  
**1、你必须到阿里云进行域名实名认证。  
2、域名信息必须在阿里云中成功通过审核。  
3、阿里云给你的key和cret，必须是正确而有效的。  
4、你要有一个公网IPV4 IP并独占(有IPV6 IP环境除外)。**    

**脚本功能说明**  
**1、安装asuswrt-merlin官方固件的路由器或安装以asuswrt-merlin源码编译的第三方固件路由器。  
1、本脚本有批量增加，批量更新，批量删除，批量验证解析记录等功能。  
2、本脚本支持N个域名解析。  
3、主机别名支持直通符@, 通配符*或具体的别名。  
4、本脚本支持IPV4和IPV6域名解析。   
5、不支持中文域名。  
6、更多功能只有使用中才发现。**       

## [更多说明请点击此处参看脚本说明文档readme.txt](https://github.com/zwmscorm/sharealiddns/blob/master/myscripts/sharealiddns/readme/readme.txt)  

## 安装方法：
**准备好winscp和xshell工具软件，如国产FinalShell免费版软件，在xshell或FinalShell命令行窗口中粘贴下面安装指令：**    
*--------------------------------------------------分割线下是安装指令-----------------------------------------------------------*  
***cd /tmp/;wget --no-check-certificate -O /tmp/install.sh [https://raw.githubusercontent.com/zwmscorm/sharealiddns/master/myscripts/install.sh;sh](https://raw.githubusercontent.com/zwmscorm/sharealiddns/master/myscripts/install.sh;sh) /tmp/install.sh***     
*--------------------------------------------------分割线上是安装指令-----------------------------------------------------------*  
**然后按提示进行操作：**  
**1、将脚本安装到jffs，则输入jffs，将脚本安装到usb，则输入usb，删除脚本，则输入uninstall。  
2、接下来是设置aliddns.conf参数，请按readme.txt文档中的说明认真填写。   
3、接下来脚本会自动运行，请注意观察脚本运行情况。如出现错误，会有提示。   
	 如果aliddns.conf参数设置错误，请运行下面的指令(假设脚本安装到jffs)，重新设置参数：**  
	 ***sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh setconf***  
	 **或者使用winscp直接进入/jffs/myscripts/sharealiddns/conf目录对aliddns.conf进行修改。**  
   **大部分情况都是参数设置不正确，使得脚本运行出现错误。**  
**4、至此，脚本已经安装完毕。**    
***一行指令就完成了脚本的安装工作，是不是很简单!***

***部分运行脚本指令(假设脚本安装到jffs):***  
***1，增加或更新所有域名：***  
***sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh restart***  
 ***2，检测所有域名是否成功解析：***   
        ***sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh check***   
***3、删除所有域名:***  
        ***sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh remove 0***  
***4、监控域名解析：***  
        ***sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh monitor***  
	

***更多指令参看readme.txt***
