#!/bin/sh
logs(){
    Y_COLOR="\033[0;33;40m"
    YB_COLOR="\033[1;33;40m"
	INFO="${Y_COLOR}INFO:${N_COLOR}"
	N_COLOR="\033[0m"
	echo -e "${INFO}${YB_COLOR}${1}${N_COLOR}"
	logger  "$1"
	return 0
}
do_install(){
    local INSTALL_PATH="$1";local SH="$2";local TAR=`which tar`;local WGET=`which wget`;local MOUNT=`which mount`
	local DOWN_URL="https://codeload.github.com/zwmscorm/sharealiddns/tar.gz/master"
	local TMP_PATH="/tmp/sharealiddns-master"
	local TAR_GZ="$TMP_PATH.tar.gz"
	local SCRIPTS_PATH=""
	local i=1;local m="";local s="";local l=""
	logs "Going..."
	[ -z "$TAR" -o -z "$WGET" -o -z "$MOUNT" -o -z `which uname` ] && logs "No wget or tar or mount was found[缺少关键性文件]" && exit 0
    trap "rm -rf /tmp/install.sh;rm -rf $TMP_PATH;rm -rf $TAR_GZ;echo '';logs 'Exit installation.';exit" SIGHUP SIGINT SIGQUIT SIGTERM  
	#check firmware
	if $(uname -o | tr 'A-Z' 'a-z' | grep -q 'merlin');then
		SCRIPTS_PATH=""
    else
        logs "The script does not support this firmware[脚本不支持此固件]" && exit 0	
    fi
	#check INSTALL_PATH vlue
	if [ -z "$INSTALL_PATH" ];then
	    logs "Next you need to type from the keyboard. To interrupt the operation, press ctrl+c[以下需要你从键盘输入, 如想中断操作, 请按ctrl+c]"
	    echo -en "${INFO}${YB_COLOR}Please enter jffs, USB or uninstall[请你输入jffs, usb或uninstall]${N_COLOR}"
	    echo -en "$YB_COLOR=>[jffs, usb, uninstall]:${N_COLOR}"
	    while :;do
            read v
		    v=$(echo "$v" | sed 's/[[:space:]]//g' | tr 'A-Z' 'a-z')
		    if [ "$v" == "jffs" -o "$v" == "usb" -o "$v" == "uninstall" ];then
		        INSTALL_PATH="$v"
		        break
		    else
		        echo -en "${INFO}${YB_COLOR}Please enter jffs, USB or uninstall[请你输入jffs, usb或uninstall]${N_COLOR}"
	            echo -en "$YB_COLOR=>[jffs, usb, uninstall]:${N_COLOR}"
		    fi
	    done
	fi
	INSTALL_PATH=$(echo "$INSTALL_PATH" | sed 's/[[:space:]]//g' | tr 'A-Z' 'a-z')
	if [ "$INSTALL_PATH" != "jffs" -a "$INSTALL_PATH" != "usb" -a "$INSTALL_PATH" != "uninstall" ];then
	    logs "Parameters must be jffs, usb or uninstall[参数必须是jffs、usb或uninstall]" 
		logs "Installation to jffs example[安装到jffs示例]: sh $SH jffs"
		logs "Installation to usb example[安装到usb示例]: sh $SH usb"
		logs "Uninstallation all example[卸载示例]: sh $SH uninstall"
		exit 0
	fi
	#uninstall all
    if [ "$INSTALL_PATH" == "uninstall" ];then
	    _uninstall_ "all"
	    exit 0
	fi
	#selecte jffs or usb
	logs "Installing to $INSTALL_PATH[将安装到${INSTALL_PATH}]"
	if [ "$INSTALL_PATH" == "jffs" ];then
	    SCRIPTS_PATH="/jffs/myscripts" 
	elif [ "$INSTALL_PATH" == "usb" ];then
	    nvram set jffs2_enable=1
	    nvram set jffs2_scripts=1
	    nvram commit
        chmod +x  /jffs/scripts/*
	    logs "Find available active partitions[查找可用的活动分区]"
        for j in $($MOUNT | grep -w 'mnt' | cut -d ' ' -f3);do
		    logs "$i=>$j"
            eval m$i=$j
		    i=$(($i+1))
        done
        if [ $i == "1" ];then
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
			        l=$(echo $s | awk -F '/mnt/' '{print $2}')	
			        if echo -e "$l" | grep -q '^[a-zA-Z0-9]\+$' && [ $(echo ${#l}) -ge 5 ];then
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
	#Download and tar
	logs "Please wait while you download it[正在下载, 请稍候]"
	rm -rf "$TAR_GZ"
    rm -rf "$TMP_PATH"
	"$WGET" --no-check-certificate -c -q -O "$TAR_GZ" "$DOWN_URL"
	if [ $? -eq 0 -a -f "$TAR_GZ" ];then
	    logs "Download successful[下载成功]" 
		"$TAR" -xzf "$TAR_GZ" -C "/tmp/"
	    if [ $? -ne 0 -o ! -d "$TMP_PATH/myscripts/lib" -o ! -d "$TMP_PATH/myscripts/sharealiddns" ];then
		    logs "Tar failed, Please reinstall[tar解压失败, 请重新安装]" 
		    rm -rf "$TAR_GZ"
		    rm -rf "$TMP_PATH"
		    exit 0
	    fi
	else
	    logs "Download failed. Please check that the network or wget version is too old and GitHub refuses[下载失败, 请检查网络或wget版本是否太旧, 被Github拒绝]" && exit 0
	fi
	#Install
    mkdir -p "$SCRIPTS_PATH"    
	[ -f "$SCRIPTS_PATH/sharealiddns/conf/aliddns.conf" ] && mv -f "$SCRIPTS_PATH/sharealiddns/conf/aliddns.conf" "$SCRIPTS_PATH/sharealiddns/conf/aliddns.conf.backup"
	if [ "$INSTALL_PATH" == "jffs" ];then
	    _uninstall_ "usb" 
	elif [ "$INSTALL_PATH" == "usb" ];then
	    _uninstall_ "jffs" 
	fi
	cp -af "$TMP_PATH/myscripts/lib" "$SCRIPTS_PATH"
	cp -af "$TMP_PATH/myscripts/sharealiddns" "$SCRIPTS_PATH"
	rm -rf "$TAR_GZ"
	rm -rf "$TMP_PATH"
	if [ -f "$SCRIPTS_PATH/lib/share.lib" -a -f "$SCRIPTS_PATH/sharealiddns/etc/init.d/sharealiddns.sh" -a -f "$SCRIPTS_PATH/sharealiddns/conf/aliddns.conf" ];then
		chmod +x "$SCRIPTS_PATH/lib/share.lib"
		chmod +x "$SCRIPTS_PATH/sharealiddns/etc/init.d/sharealiddns.sh"
		logs "Successfully install to $SCRIPTS_PATH[成功安装到${SCRIPTS_PATH}]"
		sh "$SCRIPTS_PATH/sharealiddns/etc/init.d/sharealiddns.sh" "setconf"
	else
		logs "Installation script failed, Please check[安装脚本失败, 请检查]" 
		rm -rf "$TAR_GZ"
	    rm -rf "$TMP_PATH"
		exit 0
	fi
}
_uninstall_(){
    #uninstall
	local s="$1";local r=0
    if [ "$s" == "jffs" ];then
		if [ -d "/jffs/myscripts/sharealiddns" ];then
		    rm -rf "/jffs/myscripts/sharealiddns"
		fi
	elif [ "$s" == "usb" ];then
		for j in $($MOUNT | grep -w 'mnt' | cut -d ' ' -f3);do
		    if [ -d "$j/myscripts/sharealiddns" ];then
		        rm -rf "$j/myscripts/sharealiddns"
			fi
		    i=$(($i+1))
        done
	elif [ "$s" == "all" ];then
	    if [ -d "/jffs/myscripts/sharealiddns" ];then
		    r=1
		    rm -rf "/jffs/myscripts/sharealiddns"
			logs "Successful uninstallation from /jffs/myscripts/sharealiddns[已成功从/jffs/myscripts/sharealiddns卸载]"
		fi
		for j in $($MOUNT | grep -w 'mnt' | cut -d ' ' -f3);do
		    if [ -d "$j/myscripts/sharealiddns" ];then
			    r=1
		        rm -rf "$j/myscripts/sharealiddns"
			    logs "Successful uninstallation from $j/myscripts/sharealiddns[已成功从${j}/myscripts/sharealiddns卸载]"
			fi
		    i=$(($i+1))
        done
		[ "$r" -eq 0 ] && logs "Has been uninstallation[已卸载]"
	fi
	for v in "/jffs/scripts/wan-start" "/jffs/scripts/ddns-start" "/jffs/scripts/post-mount";do
		if [ -f "$v" ];then
	        sed -i "/myshell.*/d" "$v"
		    sed -i "/myshellproc.*/d" "$v"
			sed -i "/mymnt.*/d" "$v"
			sed -i "/myservice.*/d" "$v"
			sed -i "/wan_start.*/d" "$v"
            sed -i "/restart_dhcp6c.*/d" "$v"
            sed -i '/^\s*$/d' "$v"			
	    fi
	done
}
do_install "$1" "$0"



