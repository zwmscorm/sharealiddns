#!/bin/sh
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
TAR=`which tar`;MOUNT=`which mount`;BN=`which basename`;OPENSSL=`which openssl`;NSLOOKUP=`which nslookup`
SORT=`which sort`;IP=`which ip`;WGET=`which wget`;CURL=`which curl`;OS_TYPE="";PT="";isIPV6=0
logs(){
    Y_COLOR="\033[0;33;40m"
    YB_COLOR="\033[1;33;40m"
	INFO="${Y_COLOR}INFO:${N_COLOR}"
	N_COLOR="\033[0m"
	echo -e "${INFO}${YB_COLOR}${1}${N_COLOR}"
	logger  "$1"
	return 0
}

get_os_type(){
    clear 
	logs "Going..."
	if $(uname -a | tr 'A-Z' 'a-z' | grep -q 'merlin') && [ -d "/jffs" ] ;then
	    OS_TYPE="merlin"
		[ "$(nvram get ipv6_service | tr 'A-Z' 'a-z')" == "disabled" ] && isIPV6=1
		PT="/jffs"		
    elif [ -n $(which restart_wan) ] && [ -f "/etc/storage/post_wan_script.sh" ];then
	    OS_TYPE="padavan"
		[ -z "$(nvram get ip6_service | tr 'A-Z' 'a-z')" ] && isIPV6=1
		PT="/etc/storage"
    elif $(uname -a | tr 'A-Z' 'a-z' | grep -q 'pandorabox');then
	    OS_TYPE="pandorabox"
		PT="/etc"
		[ $(cat /etc/config/network | tr 'A-Z' 'a-z' | grep -w 'ipv6' | awk '{print $3}' | sed "s/'//g" | sed 's/"//g') == "0" ] && isIPV6=1
    elif $(uname -a | tr 'A-Z' 'a-z' | grep -q 'openwrt');then
	    OS_TYPE="openwrt"
		PT="/etc"
		[ $(cat /etc/config/network | tr 'A-Z' 'a-z' | grep -w 'ipv6' | awk '{print $3}' | sed "s/'//g" | sed 's/"//g') == "0" ] && isIPV6=1
    elif [ -f "/etc/config/network" -a -d "/etc/hotplug.d/iface" ];then
        OS_TYPE="openwrt"
		[ $(cat /etc/config/network | tr 'A-Z' 'a-z' | grep -w 'ipv6' | awk '{print $3}' | sed "s/'//g" | sed 's/"//g') == "0" ] && isIPV6=1
		PT="/etc"
    else
	    logs "The script does not support this firmware[脚本不支持此固件]" "" "ra" "e"
		return 1
    fi
	logs "OS is $OS_TYPE[固件系统是${OS_TYPE}]"
	if [ "$isIPV6" == "0" ];then
	    logs "Firmware is IPV6 enabled[固件已启用IPV6]"
	else
	    logs "Firmware is IPV6 disabled[固件已禁用IPV6]"
	fi
	if [ -n "$OS_TYPE" ];then
	    return 0
	else
	    return 1
	fi
}

do_check(){
	[ -z "$TAR" ] && logs "You have to install tar[你必须安装tar]" && exit 0
	[ -z "$MOUNT" ] && logs "You have to install mount[你必须安装mount]" && exit 0
	[ -z "$BN" ] && logs "You have to install basename[你必须安装basename]" && exit 0
	[ -z "$NSLOOKUP" ] && logs "You have to install nslookup[你必须安装nslookup]" && exit 0
	[ -z "$SORT" ] && logs "You have to install sort[你必须安装sort]" && exit 0
	[ -z "$IP" ] && logs "You have to install ip[你必须安装ip]" && exit 0
	[ -z "$OPENSSL" ] && logs "You have to install openssl[你必须安装openssl]" && exit 0
	[ -z "$OPENSSL" ] && logs "You have to install openssl[你必须安装openssl]" && exit 0
	[ -z "$WGET" ] && logs "You have to install wget[你必须安装wget]" && exit 0
	return 0
}

do_install(){
    local INSTALL_PATH="$1";local SH="$2"
	local DOWN_URL="https://codeload.github.com/zwmscorm/sharealiddns/tar.gz/master"
	local TMP_PATH="/tmp/sharealiddns-master"
	local TAR_GZ="$TMP_PATH.tar.gz"
	local SCRIPTS_PATH=""
	local i=1;local m="";local s="";local l="";local n=0;local r="";local p4="";local p6=""
	local u4="http://ipv4.ident.me http://ipv4.icanhazip.com http://nsupdate.info/myip http://whatismyip.akamai.com http://ipv4.myip.dk/api/info/IPv4Address"
	local u6="http://ipv6.ident.me http://ipv6.icanhazip.com http://ipv6.ident.me http://ipv6.icanhazip.com http://ipv6.yunohost.org"
	
	trap "rm -rf $TMP_PATH;rm -rf $TAR_GZ;echo '';logs 'Exit installation.';exit" SIGHUP SIGINT SIGQUIT SIGTERM 
	
	if [ "$OS_TYPE" == "merlin" ];then
	    nvram set jffs2_enable=1
	    nvram set jffs2_scripts=1
	    nvram commit
        [ -d "/jffs/scripts" ] && chmod +x /jffs/scripts/*
	fi
		
	#check INSTALL_PATH vlue
	if [ -z "$INSTALL_PATH" ];then
	    logs "Next you need to type from the keyboard. To interrupt the operation, press ctrl+c[以下需要你从键盘输入, 如想中断操作, 请按ctrl+c]"
	    echo -en "${INFO}${YB_COLOR}Please enter nand, USB or uninstall[请输入nand, usb或uninstall]${N_COLOR}"
	    echo -en "$YB_COLOR=>[nand, usb, uninstall]:${N_COLOR}"
	    while :;do
            read v
		    v=$(echo "$v" | sed 's/[[:space:]]//g' | tr 'A-Z' 'a-z')
		    if [ "$v" == "nand" -o "$v" == "usb" -o "$v" == "uninstall" ];then
		        INSTALL_PATH="$v"
		        break
		    else
		        echo -en "${INFO}${YB_COLOR}Please enter nand, USB or uninstall[请输入nand, usb或uninstall]${N_COLOR}"
	            echo -en "$YB_COLOR=>[nand, usb, uninstall]:${N_COLOR}"
		    fi
	    done
	fi
	INSTALL_PATH=$(echo "$INSTALL_PATH" | sed 's/[[:space:]]//g' | tr 'A-Z' 'a-z')
	if [ "$INSTALL_PATH" != "nand" -a "$INSTALL_PATH" != "usb" -a "$INSTALL_PATH" != "uninstall" ];then
	    logs "Parameters must be nand, usb or uninstall[参数必须是nand、usb或uninstall]" 
		logs "Installation to nand example[安装到nand示例]: sh $SH nand"
		logs "Installation to usb example[安装到usb示例]: sh $SH usb"
		logs "Uninstallation all example[卸载示例]: sh $SH uninstall"
		exit 0
	fi
	#uninstall all
    if [ "$INSTALL_PATH" == "uninstall" ];then
	    _uninstall_ "all"
	    exit 0
	fi
	#selecte nand or usb
	logs "Installing to $INSTALL_PATH[将安装到${INSTALL_PATH}]"
	if [ "$INSTALL_PATH" == "nand" ];then
	    SCRIPTS_PATH="$PT/myscripts" 
	elif [ "$INSTALL_PATH" == "usb" ];then
	    logs "Find available active partitions[查找可用的活动分区]"
		if [ "$OS_TYPE" == "merlin" -o "$OS_TYPE" == "padavan" ];then
			n=5
        else
            n=4		
		fi
        for j in $($MOUNT | grep -v 'tmpfs' | grep -wE 'mnt|media|opt' | cut -d ' ' -f3);do
		    if [ -n $($BN $j) ];then
		        logs "$i=>$j"
                eval m$i=$j
			    i=$(($i+1))
			fi
        done
        if [ "$i" -eq 1 ];then
		    logs "No active partition was found available[找不到可用的活动分区]" 
			rm -rf "$TAR_GZ"
	        rm -rf "$TMP_PATH"
		    exit 0
		fi
	    echo -en "${INFO}${YB_COLOR}Please enter the partition number and press 0 to exit[请输入分区号按0将退出]${N_COLOR}"
	    echo -en "$YB_COLOR=>[0~$(($i-1))]:${N_COLOR}"
	    while :;do
            read v
	        if [ "$v" -ge 0 2>/dev/null ];then
	            [ "$v" == "0" ] && break
	            if [ "$v" -gt $(($i-1)) ];then
                    logs "Invalid partition number, reinput[分区号无效, 重输]"
				    echo -en "${INFO}${YB_COLOR}Please enter the partition number and press 0 to exit[请输入分区号按0将退出]${N_COLOR}"
	                echo -en "$YB_COLOR=>[0~$(($i-1))]:${N_COLOR}"
 	            else 
                    eval s=\$m$v
					l=$($BN $s)
			        if echo -e "$l" | grep -q '^[a-zA-Z0-9]\+$' && [ $(echo ${#l}) -ge "$n" ];then
	                    logs "The selected active partition is ${s}[选定的活动分区是${s}]"
						SCRIPTS_PATH="$s/myscripts" 
					    break
                    else
		                logs "USB partition volume label must be set to English or numeric, and the total number must exceed 4 digits[usb分区卷标必须设置为英文或数字，总数必须超过4位]"
	                    echo -en "${INFO}${YB_COLOR}Please enter the partition number and press 0 to exit[请输入分区号按0将退出]${N_COLOR}"
	                    echo -en "$YB_COLOR=>[0~$(($i-1))]:${N_COLOR}"
					fi
					
                fi
	        else
	            logs "The partition number must be a number, reinput[分区号必须是数字, 重输]"
			    echo -en "${INFO}${YB_COLOR}Please enter the partition number and press 0 to exit[请输入分区号按0将退出]${N_COLOR}"
	            echo -en "$YB_COLOR=>[0~$(($i-1))]:${N_COLOR}"
	        fi
	    done
	fi
	if [ -z "$SCRIPTS_PATH" ];then
	    logs "Installation path is not determined[安装路径没确定好]"
	    rm -rf "$TAR_GZ"
	    rm -rf "$TMP_PATH"
	    exit 0
	fi
	
	#Firmware compatibility is being check
	logs "Firmware compatibility is being check...[正在检测固件兼容性...]"
	if [ -n "$OPENSSL" ];then
        r=$('A' | $OPENSSL dgst -sha1 -hmac 'a' -binary | $OPENSSL base64) 2>/dev/null
	    if [ $? -eq 0 -a -n "$r" ];then
	        r=""
	    else
			logs "$OPENSSL is unavailable[${OPENSSL}无法使用]"
			exit 0
	    fi
	fi
	r="1"
	for u in $u4;do
	    p4=$($WGET --no-check-certificate -q -T 10 -O- $u) 2>/dev/null
	    [ $? -eq 0 -a -n "$p4" ] && r="0" && break   
	done
	if [ "$r" != "0" ];then
	    logs "$WGET version is too low or firmware is not supported, please upgrade[${WGET}版本太低或固件不支持, 请升级。]"
		exit 0
	fi
	r="1"
	if [ "$isIPV6" == "0" ];then
	    for u in $u6;do
	        p6=$($WGET --no-check-certificate -T 10 -O- $u) 2>/dev/null
	        [ $? -eq 0 -a -n "$p6" ] && r="0" && break    
	    done
		if [ "$r" != "0" ];then
		    logs "$WGET version is too low or firmware is not supported, please upgrade[${WGET}版本太低或固件不支持, 请升级。]"
	    fi
	fi
	#Download and tar
	logs "Please wait while you download it[正在下载, 请稍候]"
	rm -rf "$TAR_GZ"
    rm -rf "$TMP_PATH"
	i=1;r="1"
	while [ $i -le 10 ];do
	    if [ "$r" == "1" -a -n "$WGET" ];then
	        "$WGET" --no-check-certificate -c -q -O "$TAR_GZ" "$DOWN_URL"
		    [ $? -eq 0 -a -f "$TAR_GZ" ] && r="0"
	    fi
	    if [ "$r" == "1" -a -n "$CURL" ];then	
	        "$CURL" -k "$DOWN_URL" -o "$TAR_GZ"
		    [ $? -eq 0 -a -f "$TAR_GZ" ] && r="0"
        fi	 
	    [ "$r" == "0" ] && break
	    i=$((i+1))
	done
	if [ "$r" == "0" ];then
	    logs "Download successful[下载成功]" 
		"$TAR" -xzf "$TAR_GZ" -C "/tmp/"
	    if [ $? -ne 0 -o ! -d "$TMP_PATH/myscripts/lib" -o ! -d "$TMP_PATH/myscripts/sharealiddns" ];then
		    logs "Tar failed, Please reinstall[tar解压失败, 请重新安装]" 
		    rm -rf "$TAR_GZ"
		    rm -rf "$TMP_PATH"
		    exit 0
	    fi
	else
	    logs "The download failed because of slow network or because HTTPS was rejected by GitHub[下载失败, 因网络慢，或因https被github拒绝]" && exit 0
	fi
 
	#Install
    mkdir -p "$SCRIPTS_PATH" 
    chmod +x "$SCRIPTS_PATH" 	
	[ -f "$SCRIPTS_PATH/sharealiddns/conf/aliddns.conf" ] && mv -f "$SCRIPTS_PATH/sharealiddns/conf/aliddns.conf" "$SCRIPTS_PATH/sharealiddns/conf/aliddns.conf.backup"
	if [ "$INSTALL_PATH" == "nand" ];then
	    _uninstall_ "usb" 
	elif [ "$INSTALL_PATH" == "usb" ];then
	    _uninstall_ "nand" 
	fi
	
	cp -af "$TMP_PATH/myscripts/lib" "$SCRIPTS_PATH"
	cp -af "$TMP_PATH/myscripts/sharealiddns" "$SCRIPTS_PATH"
	rm -rf "$TAR_GZ"
	rm -rf "$TMP_PATH"
	
	if [ -f "$SCRIPTS_PATH/lib/share.lib" -a -f "$SCRIPTS_PATH/sharealiddns/etc/init.d/sharealiddns.sh" -a -f "$SCRIPTS_PATH/sharealiddns/conf/aliddns.conf" ];then
		chmod +x "$SCRIPTS_PATH/lib/share.lib"
		chmod +x "$SCRIPTS_PATH/sharealiddns/etc/init.d/sharealiddns.sh"
		logs "Successfully install to $SCRIPTS_PATH[成功安装到${SCRIPTS_PATH}]"
		sleep 3
		if [ -x "$SCRIPTS_PATH/sharealiddns/etc/init.d/sharealiddns.sh" ];then
		    "$SCRIPTS_PATH/sharealiddns/etc/init.d/sharealiddns.sh" "setconf" 2>/dev/null
		fi
	else
		logs "Installation script failed, Please check[安装脚本失败, 请检查]" 
		rm -rf "$TAR_GZ"
	    rm -rf "$TMP_PATH"
	fi
}

_uninstall_(){
    #uninstall
	local s="$1";local r=0
    if [ "$s" == "nand" ];then
		if [ -d "$PT/myscripts/sharealiddns" ];then
		    rm -rf "$PT/myscripts/sharealiddns"
		fi
	elif [ "$s" == "usb" ];then
		for j in $($MOUNT | grep -wE 'mnt|media|opt' | cut -d ' ' -f3);do
		    if [ -d "$j/myscripts/sharealiddns" ];then
		        rm -rf "$j/myscripts/sharealiddns"
			fi
		    i=$(($i+1))
        done
	elif [ "$s" == "all" ];then
	    if [ -d "$PT/myscripts/sharealiddns" ];then
		    r=1
		    rm -rf "$PT/myscripts/sharealiddns"
			logs "Successful uninstallation from $PT/myscripts/sharealiddns[已成功从$PT/myscripts/sharealiddns卸载]"
		fi
		for j in $($MOUNT | grep -wE 'mnt|media|opt' | cut -d ' ' -f3);do
		    if [ -d "$j/myscripts/sharealiddns" ];then
			    r=1
		        rm -rf "$j/myscripts/sharealiddns"
			    logs "Successful uninstallation from $j/myscripts/sharealiddns[已成功从${j}/myscripts/sharealiddns卸载]"
			fi
		    i=$(($i+1))
        done
		[ "$r" == "0" ] && logs "Has been uninstallation[已卸载]"
	fi
	if [ "$OS_TYPE" == "merlin" ];then
	    for v in "/jffs/scripts/wan-start" "/jffs/scripts/ddns-start" "/jffs/scripts/post-mount";do
		    if [ -f "$v" ];then
			    _rmspacekeyfile_ "$v" "myshell"		
	            _rmspacerowfile_ "$v"
			    if [ "$v" == "/jffs/scripts/wan-start" ];then
				    _rmcurrowtolistfile_ "$v" "myshell" 14
				else
				    _rmrowfile_ "$v" "myshell"
				    _rmrowfile_ "$v" "myshellname"
				    _rmrowfile_ "$v" "myshellproc"
				    #del old
				    _rmrowfile_ "$v" "myservice"
				    _rmrowfile_ "$v" "wan_start"
				    _rmrowfile_ "$v" "restart_dhcp6c"
                    _rmspacerowfile_ "$v"
				fi
	        fi
	    done
	elif [ "$OS_TYPE" == "padavan" ];then
	    if [ -f "/etc/storage/post_wan_script.sh" ];then
		    _rmspacekeyfile_     "/etc/storage/post_wan_script.sh" "myshell"		
	        _rmspacerowfile_     "/etc/storage/post_wan_script.sh"
			_rmcurrowtolistfile_ "/etc/storage/post_wan_script.sh" "myshell" 14
			_rmspacerowfile_     "/etc/storage/post_wan_script.sh"
		fi
	elif [ "$OS_TYPE" == "openwrt" -o "$OS_TYPE" == "pandorabox" ];then
	    rm -rf "/etc/hotplug.d/iface/99-sharealiddns"   
		rm -rf "/etc/init.d/sharealiddns" 
	fi
}

_rmspacekeyfile_(){
    local f="$1";local w="$2"
	sed -i "s~  *${w}~${w}~g" "$f"
    sed -i "s~${w}  *~${w}~g" "$f"
}

_rmspacerowfile_(){
    sed -i '/^\s*$/d' "$1" 
}

_rmcurrowtolistfile_(){
    local f="$1";local w="$2";local n="$3"
    sed -i "/${w}/,+${n}d" "$f"
}

_rmrowfile_(){
    local f="$1";local w="$2"
	sed -i "/${w}/d" "$f"
}

get_os_type && do_check && do_install "$1" "$0"          
#=========================================the end====================================#
