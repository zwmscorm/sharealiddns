# sharealiddns脚本说明文档：
**sharealiddns脚本是共享的，你可自由下载和使用，但不得用于商业目的，引用时请注明来源。
本脚本当初是放在国内的K&S论坛上方便大家下载和使用，但经常习惯性地被K&S屏蔽，这就不符合
共享精神了，所以决定放在全球知名的开源github上共大家下载和使用。个人看来，K&S后面的S
可以删除了，你觉得呢？**  

**脚本使用条件：**  
**1、你必须到阿里云进行域名实名认证。  
2、域名信息必须在阿里云中成功通过审核。  
3、阿里云给你的key和cret，必须是正确而有效的。  
4、你要有一个公网IPV4 IP并独占(有IPV6 IP环境除外)。**    

**脚本功能说明**  
**1、本脚本有增加，更新，删除，验证解析记录等功能。  
2、本脚本支持N个域名批量解析。  
3、主机别名支持直通符@, 通配符*或具体的别名。  
4、本脚本支持IPV4和IPV6域名解析。   
5、不支持中文域名。**       



## [更多说明请点击此处参看脚本文档readme.txt](https://github.com/zwmscorm/sharealiddns/blob/master/myscripts/sharealiddns/readme/readme.txt)  

## 安装方法：
**准备好winscp和xshell工具软件，如国产FinalShell免费版软件，在xshell或FinalShell命令行窗口中粘贴下面指令：**      
***cd /tmp/;wget --no-check-certificate -O /tmp/install.sh [https://raw.githubusercontent.com/zwmscorm/sharealiddns/master/myscripts/install.sh;sh](https://raw.githubusercontent.com/zwmscorm/sharealiddns/master/myscripts/install.sh;sh) /tmp/install.sh***  
**然后按提示进行操作：**  
**1、将脚本安装到jffs，则输入jffs，将脚本安装到usb，则输入usb，删除脚本，则输入uninstall。  
2、接下来是设置aliddns.conf参数，请按readme.txt文档中的说明认真填写。   
3、接下来脚本会自动运行，请注意观察脚本运行情况。如出现错误，会有提示。   
	 如果aliddns.conf参数设置错误，请运行下面的脚本(假设脚本安装到jffs)，重新设置参数：  
	 sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh setconf  
	 或者直接进入/jffs/myscripts/sharealiddns/conf目录对aliddns.conf进行修改。  
   大部分情况都是参数设置不正确，使得脚本运行出现错误。  
4、至此，脚本已经安装完毕。**  

***简单运行脚本指令（更多指令参看readme.txt）启动脚本：***    
***sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh start***  
***或者：***  
***sh /jffs/myscripts/sharealiddns/etc/init.d/sharealiddns.sh restart***  

