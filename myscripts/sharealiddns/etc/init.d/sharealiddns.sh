#!/bin/sh
#======================================================================================
export PATH=/usr/bin:/usr/sbin:/usr/lib:/bin:/sbin:/lib:$PATH
#======================================================================================
get_scripts_path(){
	local d=`which dirname`
	local p=`which pwd`
	local r=`which readlink`
	if [ -n "$d" -a -n "$r" ];then
	    echo $($d $($r -f $1))
	elif [ -n "$d" -a -n "$p" ];then
	    echo $(cd $($d $1);$p)
	else
	    echo ""
	fi
}
#======================================================================================
get_scripts_folder(){
    echo `echo $1 | awk -F "/etc/init.d" '{print $1}'`
}
#======================================================================================
get_scripts_folder_name(){
    local b=`which basename`
	if [ -n "$b" ];then
        echo $($b $1) 
	else
	    echo ""
	fi  
}
#======================================================================================
get_scripts_mount_path(){
    local d=`which dirname`
	if [ -n "$d" ];then
        echo $($d $1)
	else
	    echo ""
	fi
}
#======================================================================================
get_scripts_mount_name(){
    local d=`which dirname`
	if [ -n "$d" ];then
        echo $($d $1)
	else
	    echo ""
	fi
}
#======================================================================================
get_scripts_name(){
    local b=`which basename`
	if [ -n "$b" ];then
        echo $($b $1)
    else
        echo ""
	fi
}
#======================================================================================
get_scripts_sh(){
    if [ -z "$(echo $1 | grep -o "/")" ];then
        echo "$2/$3"  
    else
        echo "$1"  
    fi
}
#======================================================================================
scripts_path=$(get_scripts_path $0)
scripts_folder=$(get_scripts_folder $scripts_path)
scripts_folder_name=$(get_scripts_folder_name $scripts_folder)
scripts_mount_path=$(get_scripts_mount_path $scripts_folder)
scripts_mount_name=$(get_scripts_mount_name $scripts_mount_path)
scripts_name=$(get_scripts_name $0) 
scripts_sh=$(get_scripts_sh $0 $scripts_path $scripts_name) 
#======================================================================================
aliddns_title="aliddns_plugin"
aliddns_version="12.0"
aliddns_dcu="/sbin/ddns_custom_updated"
aliddns_root="$scripts_folder"
aliddns_conf="$aliddns_root/conf/aliddns.conf"
aliddns_log="$aliddns_root/log/log.txt"
aliddns_msg="/tmp/aliddns_msg.txt"
#======================================================================================
chmod 0755 "$scripts_sh"
#======================================================================================
share_path="$scripts_mount_path/lib/share.lib"
if [ -f "$share_path" ];then
   [ ! -x "$share_path" ] && chmod 0755 "$share_path" >/dev/null 2>&1
   source "$share_path"
else
   echo -e "Can't find $share_path."
   logger  "Can't find $share_path."
   exit 0 
fi
#======================================================================================
ARGS0="$0";ARGS2="$2";ARGS3="$3";ARGS4="$4";LS="$logsplit"
#======================================================================================
ARGS1=$(echo $1 | awk -F '_' '{print $1}')
FU=$(echo $1 | awk -F '_' '{print $2}');FL="/tmp/$scripts_name.lock";FS="$scripts_sh";FD=100
if isexists "flock";then
    xnlock "$FD" "$FL" "$FS" "$FU" || lock_info "$FS"
else
    fflock "$FD" "$FL" "$FS" "$FU" || lock_info "$FS"
fi
#======================================================================================
logs "" "$LS"
[ -n "$KERNEL_RELEASE" ] && logs "$ROUTER_MODEL KERNEL_RELEASE IS $KERNEL_RELEASE" "" "yb"
[ -n "$KERNEL_VER" ] && logs "$ROUTER_MODEL KERNEL_VER IS $KERNEL_VER"             "" "yb"
[ -n "$MACHINE_TYPE" ] && logs "$ROUTER_MODEL MACHINE_TYPE IS $MACHINE_TYPE"       "" "yb"
[ -n "$BUILDNO" ] && logs "$ROUTER_MODEL BUILDNO IS $BUILDNO"                      "" "yb"
[ -n "$OS_TYPE" ] && logs "$ROUTER_MODEL FIRMWARE IS $OS_TYPE"                     "" "yb"
#======================================================================================
logs "SHAREALIDDNS VERSION IS $aliddns_version" "" "yb"
#======================================================================================
#======================================================================================
#======================================================================================
logs "$ARGS0 $ARGS1 $ARGS2 $ARGS3 $ARGS4" "$LS" "rb"
#======================================================================================
#0:close debug
#1:get_aliddns_options
#2:aliddns_domain_api and get_Record
ndebug=0
#======================================================================================
isGEbetween 0 "$ARGS4" 2 && ndebug="$ARGS4"
#======================================================================================
islog=0
isipv4_domain=0
isipv6_domain=0
pppoe_ifname="any"
cron_Time=1
cron_Time_type="hour"
cron_File=""
#======================================================================================
routerddns_no=1
routerddns_name=""
routerddns_domain=""
#======================================================================================
#ipv4 external url
u4=""
#ipv6 external url
u6=""
#nslookup server
dns=""
#======================================================================================
#First use wage, curl Can not be installed
OPENSSL=""
NSLOOKUP="" 
IP2="" 
CURL="" 
WGET=""
SORT="" 
#======================================================================================
wan_no=0
wan_ifname=""
wan_proto=""
wan_ipvx_IP=""
wan_ipv4_IP=""
wan_ipv6_IP=""
lan_ipvx_IP=""
lan_ipv4_IP=""
lan_ipv6_IP=""
xIP=""
xan_ipvx_IP=""
issuccess=""
isfailed=""
isdnsExist="false"
isdnsWhois=0
isPublic_network=1
isFirst_level_router=1
iscurl=1
iswget=1
isgetexternalipv4=1
isgetexternalipv6=1
num_getRecord=1
Count=1
SP="&"
currtimer=0
lasttimer=0
actions="checked"
operation="success"
ID_CRU=ID_aliddns_update
nslookup_ipvx=""
iseui64=1
ipv6_eui64=""
ipv6_prefix=""
nslookup_dns=""
isfailed_again="/tmp/isfailed_again_aliddns"
isfailed_again_num="/tmp/isfailed_again_aliddns.num"
iswan_start="/tmp/wan_start.pid"
#======================================================================================
Record_TotalCount=0
Record_Id=""
Record_IP=""      
Record_name=""    
Record_domain=""
Record_Status=""
Record_type=""
Record_Locked=""
Record_ttl=""
Record_RequestId=""
Record_Priority=""
Record_Weight=""
Record_Line=""
Record_Ids=""
Record_RecordCount=1
#======================================================================================
aliddns_domain_list=""
aliddns_name_list=""
aliddns_ttl_list=""
aliddns_type_list=""
aliddns_lan_mac_list=""	
#======================================================================================
aliddns_TotalCount=0
aliddns_name=""
aliddns_domain=""
aliddns_ttl=""
aliddns_type=""
aliddns_AccessKeyId=""
aliddns_AccessKeySecret=""
aliddns_lan_mac=""
aliddns_url_ok=""
aliddns_url="http://alidns.aliyuncs.com"
#======================================================================================
dhcp6cPID=0
wanstartPID=0
externalIP4=""
externalIP6=""
ETH=""
isIPV6=0
isRUN=0
#======================================================================================
get_url_cmd(){
    local u="$1";local t="$2";local m="$3";local p=""
	if iseq "$m" "ipv4";then
	    m=-4
	elif iseq "$m" "ipv6";then
	    m=-6
	else
	    m=""
	fi
	isEmpty "$t" && t=30
	if [ -n "$u" ];then
	    if [ -n "$WGET" ];then
	        p=$($WGET $m --no-check-certificate -q -T $t -O- $u) 2>/dev/null
        elif [ -n "$CURL" ];then
	        p=$($CURL $m -k -s --connect-timeout $t $u) 2>/dev/null
        fi
	fi
	echo "$p"
}
#======================================================================================
get_ip_wget(){
	local u="$1";local t="$2";local m="$3";local wp=""
	isEmpty "$t" && t=30
	if [ -n "$WGET" -a -n "$u" ];then
	    p=$($WGET --no-check-certificate -q -T $t -O- $u) 2>/dev/null
		if iseq $? 0;then
			if iseq "$m" "ipv4";then
				public_ipv4_check "$p" && wp="$p" 
            elif iseq "$m" "ipv6";then
				public_ipv6_check "$p" && wp="$p"
            else
                wp="$p"			
			fi
		fi
	fi
	echo "$wp"
}
#======================================================================================
get_ip_curl(){
	local u="$1";local t="$2";local m="$3";local wp=""
	isEmpty "$t" && t=30
	if [ -n "$CURL" -a -n "$u" ];then
	    p=$($CURL -k -s --connect-timeout $t $u) 2>/dev/null
		if iseq $? 0;then
			if iseq "$m" "ipv4";then
				public_ipv4_check "$p" && wp="$p" 
            elif iseq "$m" "ipv6";then
				public_ipv6_check "$p" && wp="$p"
            else
                wp="$p"			
			fi
		fi
	fi
	echo "$wp"
}
#======================================================================================
isgetexternalIPV46(){
    local m="$1";local r="";local u4="http://ipv4.ident.me";local u6="http://ipv6.ident.me"
	local f4="/tmp/isgetexternalIPV4.success";local f6="/tmp/isgetexternalIPV6.success"
    if iseq "$m" "ipv4";then
        if [ -f "$f4" ];then
            r=$(cat "$f4" | grep -w 'success' | RMSTRING 'success=')
			return "$r"
		else 
		    r=$($WGET --no-check-certificate -T 15 -O- $u4) 2>/dev/null
            if isNotEmpty "$r" ;then
	            echo "success=0" > "$f4"
                return 0
            else
	            echo "success=1" > "$f4"
                return 1
            fi
		fi
	elif iseq "$m" "ipv6";then
        if [ -f "$f6" ];then
		    r=$(cat "$f6" | grep -w 'success' | RMSTRING 'success=')
			return "$r"
		else
		    r=$($WGET --no-check-certificate -T 15 -O- $u6) 2>/dev/null
            if isNotEmpty "$r" ;then
	            echo "success=0" > "$f6"
                return 0
            else
	            echo "success=1" > "$f6"
                return 1
            fi
		fi
	fi
}
#======================================================================================
get_aliddns_options(){
	local ct=0;local n1=0;local n2=0;local n3=0;local n4=0;local n5=0;local m='"'
	local s0="$aliddns_conf";local s1="isipv4_domain";local s2="isipv6_domain";local s3="pppoe_ifname"
	local s4="cron_Time";local s5="cron_Time_type";local s6="islog";local s7="aliddns_AccessKeyId"
	local s8="aliddns_AccessKeySecret";local s9="routerddns_no"
	local s10="aliddns_name";local s11="aliddns_domain";local s12="aliddns_ttl";local s13="aliddns_type";local s14="aliddns_lan_mac"
	
	LTRIMFILE "$s0"	
	RTRIMFILE "$s0"	
	RMSPACEROWFILE "$s0"
	sed -i 's/  *=/=/g' "$s0"
	sed -i 's/=  */=/g' "$s0"
	
	isipv4_domain=$(cat $s0  | grep -w $s1 | RMSTRING "$s1=" | RMSTRING '"' | RMSTRING "''" | TRIMALL)
    isipv6_domain=$(cat $s0  | grep -w $s2 | RMSTRING "$s2=" | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	pppoe_ifname=$(cat $s0   | grep -w $s3 | RMSTRING "$s3=" | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	cron_Time=$(cat $s0      | grep -w $s4 | RMSTRING "$s4=" | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	cron_Time_type=$(cat $s0 | grep -w $s5 | RMSTRING "$s5=" | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	islog=$(cat $s0          | grep -w $s6 | RMSTRING "$s6=" | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	aliddns_AccessKeyId=$(cat $s0     | grep -w $s7  | RMSTRING "$s7="  | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	aliddns_AccessKeySecret=$(cat $s0 | grep -w $s8  | RMSTRING "$s8="  | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	routerddns_no=$(cat $s0           | grep -w $s9  | RMSTRING "$s9="  | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	aliddns_name_list=$(cat $s0       | grep -w $s10 | RMSTRING "$s10=" | RMSTRING '"' | RMSTRING "''")
	aliddns_domain_list=$(cat $s0     | grep -w $s11 | RMSTRING "$s11=" | RMSTRING '"' | RMSTRING "''")
	aliddns_ttl_list=$(cat $s0        | grep -w $s12 | RMSTRING "$s12=" | RMSTRING '"' | RMSTRING "''")
	aliddns_type_list=$(cat $s0       | grep -w $s13 | RMSTRING "$s13=" | RMSTRING '"' | RMSTRING "''")
	aliddns_lan_mac_list=$(cat $s0    | grep -w $s14 | RMSTRING "$s14=" | RMSTRING '"' | RMSTRING "''")
	n1=$(echo "$aliddns_name_list"    | ROWTOCOLUMN | awk 'END{print NR}') 
	n2=$(echo "$aliddns_domain_list"  | ROWTOCOLUMN | awk 'END{print NR}') 
	n3=$(echo "$aliddns_ttl_list"     | ROWTOCOLUMN | awk 'END{print NR}') 
	n4=$(echo "$aliddns_type_list"    | ROWTOCOLUMN | awk 'END{print NR}') 
	n5=$(echo "$aliddns_lan_mac_list" | ROWTOCOLUMN | awk 'END{print NR}')

    u4=$(cat $s0  | grep -w 'u4'  | RMSTRING 'u4='  | RMSTRING '"' | RMSTRING "''")
	u6=$(cat $s0  | grep -w 'u6'  | RMSTRING 'u6='  | RMSTRING '"' | RMSTRING "''")
	dns=$(cat $s0 | grep -w 'dns' | RMSTRING 'dns=' | RMSTRING '"' | RMSTRING "''")
   	
	if iseq "$islog" 0 || iseq "$islog" 1;then 
	    ct=1
	else
	    logs "The value of islog must be 0 or 1, Please check." "" "rb" "e"
		return 1
	fi
	
	if iseq "$isipv4_domain" 0 || iseq "$isipv4_domain" 1;then
	    ct=1
	else
	    logs "The value of isipv4_domain must be 0 or 1, Please check." "" "rb" "e"
		return 1
	fi
	if iseq "$isipv6_domain" 0 || iseq "$isipv6_domain" 1;then
	    ct=1
	else
	    logs "The value of isipv6_domain must be 0 or 1, Please check." "" "rb" "e"
		return 1
	fi
	
	if iseq "$pppoe_ifname" "wan0" || iseq "$pppoe_ifname" "wan1" || iseq "$pppoe_ifname" "auto" || iseq "$pppoe_ifname" "any";then 
	    ct=1
	else
	    logs "The value of PPPoE must be wan0, wan1, auto or any, Please check." "" "rb" "e"
		return 1
	fi
	
	if iseq "$cron_Time_type" "hour" || iseq "$cron_Time_type" "min";then
	    ct=1
	else
	    logs "The value of cron_Time_type must be hour or min, Please check." "" "rb" "e"
		return 1
	fi
	if iseq "$cron_Time_type" "min";then
	    if isge "$cron_Time" 5 && isle "$cron_Time" 59;then
		    ct=1
        else
		    logs "The value of cron_Time must be 5~59, Please check." "" "rb" "e"
            return 1
        fi	
	elif iseq "$cron_Time_type" "hour";then
	    if isge "$cron_Time" 1 && isle "$cron_Time" 23;then
		    ct=1
        else
		    logs "The value of cron_Time must be 1~23, Please check." "" "rb" "e"
            return 1
        fi
	fi	
	
	if isNotEmpty "$u4" && isNotEmpty "$u6" && isNotEmpty "$dns";then
        ct=1
	else
	    logs "The value of u4, u6 or dns is wrong, Please check." "" "rb" "e"
	    return 1
	fi	
	
	if isNotEmpty "$aliddns_AccessKeyId";then
	    ct=1
    else
	    logs "The value of aliddns_AccessKeyId is wrong, Please check." "" "rb" "e"
		return 1
	fi	
	
	if isNotEmpty "$aliddns_AccessKeySecret";then
	    ct=1
    else
	    logs "The value of aliddns_AccessKeySecret is wrong, Please check." "" "rb" "e"
		return 1
	fi
	
	if isle "$n1" 0 || isle "$n2" 0 || isle "$n3" 0 || isle "$n4" 0 || isle "$n5" 0;then
		logs "aliddns.conf does not set parameters, Please check."  "" "rb" "e"  
		logs "aliddns_name=$m$aliddns_name_list$m"       "" "yb"
		logs "aliddns_domain=$m$aliddns_domain_list$m"   "" "yb"
		logs "aliddns_ttl=$m$aliddns_ttl_list$m"         "" "yb"
		logs "aliddns_type=$m$aliddns_type_list$m"       "" "yb"
		logs "aliddns_lan_mac=$m$aliddns_lan_mac_list$m" "" "yb"
		return 1		 
	elif isNotEmpty "$n1" && check_number "$n1" && iseq "$n1" "$n2" && iseq "$n1" "$n3" && iseq "$n1" "$n4" && iseq "$n1" "$n5" && isge "$n1" 1;then
	    aliddns_TotalCount="$n1" 	
	else
	    logs "The total number of aliddns_name, aliddns_domain, aliddns_ttl, aliddns_type or aliddns_lan_mac lists is different, Please check." "" "rb" "e"
        logs "aliddns_name column number=$n1"    "" "yb"
		logs "aliddns_domain column number=$n2"  "" "yb"
		logs "aliddns_ttl column number=$n3"     "" "yb"
		logs "aliddns_type column number=$n4"    "" "yb"
		logs "aliddns_lan_mac column number=$n5" "" "yb"
		return 1		 
	fi
	
	if isNotEmpty "$routerddns_no" && check_number "$routerddns_no";then
	    if isle "$routerddns_no" 0 || isgt "$routerddns_no" "$aliddns_TotalCount";then
	        logs "The value of routerddns_no must be 1~$aliddns_TotalCount, Please check." "" "rb" "e"
			return 1
	    fi
	else
	    logs "The value of routerddns_no must be 1~$aliddns_TotalCount, Please check." "" "rb" "e"
		return 1
	fi	
	
	routerddns_name=$(echo "$aliddns_name_list"     | awk "{print $"$routerddns_no"}" | TRIMALL)
	routerddns_domain=$(echo "$aliddns_domain_list" | awk "{print $"$routerddns_no"}" | TRIMALL)

	if iseq "$ndebug" 1;then
	    logs "*********************************************************************"
		logs "islog=$islog"                                     "" "yb"
	    logs "isipv4_domain=$isipv4_domain"                     "" "yb"
	    logs "isipv6_domain=$isipv6_domain"                     "" "yb"
	    logs "pppoe_ifname=$pppoe_ifname"                       "" "yb"
		logs "cron_Time=$cron_Time"                             "" "yb"
		logs "cron_Time_type=$cron_Time_type"                   "" "yb"
		logs "aliddns_AccessKeyId=$aliddns_AccessKeyId"         "" "yb"
	    logs "aliddns_AccessKeySecret=$aliddns_AccessKeySecret" "" "yb"
	    logs "routerddns_no=$routerddns_no"                     "" "yb"
		logs "routerddns_name=$routerddns_name"                 "" "yb"
	    logs "routerddns_domain=$routerddns_domain"             "" "yb"
		logs "*********************************************************************"
	fi
	
	if isNotEmpty "$routerddns_domain" && isNotEmpty "routerddns_name";then
        ct=1
	else
	    logs "routerddns_domain or routerddns_name has a formatted error, Please check." "" "rb" "e"
	    return 1
	fi	
	
	return 0
}
#======================================================================================
get_aliddns_conf(){
    local c="$1";local s0="$aliddns_conf";local s1="aliddns_domain";local s2="aliddns_name"
	local s3="aliddns_ttl";local s4="aliddns_type";local s5="aliddns_lan_mac"
	
	LTRIMFILE "$s0"	
	RTRIMFILE "$s0"	
	RMSPACEROWFILE "$s0"
	sed -i 's/  *=/=/g' "$s0"
	sed -i 's/=  */=/g' "$s0"
	
	aliddns_domain="";aliddns_name="";aliddns_ttl="";aliddns_type="";aliddns_lan_mac=""
	aliddns_name=$(echo "$aliddns_name_list"       | awk "{print $"$c"}" | TRIMALL)
	aliddns_domain=$(echo "$aliddns_domain_list"   | awk "{print $"$c"}" | TRIMALL)
	aliddns_ttl=$(echo "$aliddns_ttl_list"         | awk "{print $"$c"}" | TRIMALL)
	aliddns_type=$(echo "$aliddns_type_list"       | awk "{print $"$c"}" | TRIMALL)
	aliddns_lan_mac=$(echo "$aliddns_lan_mac_list" | awk "{print $"$c"}" | TRIMALL | set_lowercase)
	
	if iseq "$aliddns_type" "A" || iseq "$aliddns_lan_mac" ":" || iseq "$aliddns_lan_mac" "''" || iseq "$aliddns_lan_mac" '""' || iseq "$aliddns_lan_mac" "no" || iseq "$aliddns_lan_mac" "none" || isEmpty "$aliddns_lan_mac";then
	    aliddns_lan_mac=""
	fi
    if isNotEmpty "$aliddns_lan_mac" && ! valid_mac "$aliddns_lan_mac";then
	    logs "The value of aliddns_lan_mac[${aliddns_lan_mac}] is wrong, Please check." "" "rb" "e"
		return 1
	fi
	
    if ! check_number "$aliddns_ttl" || isle "$aliddns_ttl" 0;then
	    logs "The value of aliddns_ttl[${aliddns_ttl}] is wrong, Please check." "" "rb" "e"
		return 1
	fi
	if isEmpty "$aliddns_name";then
	    logs "The value of aliddns_name is wrong, Please check." "" "rb" "e"
		return 1
	fi
	if isEmpty "$aliddns_domain";then
	    logs "The value of aliddns_domain is wrong, Please check." "" "rb" "e"
		return 1
	fi
	if iseq "$aliddns_type" "A" || iseq "$aliddns_type" "AAAA";then
	    return 0
	else
	    logs "The value of aliddns_type must be A or AAAA, Please check." "" "rb" "e"
		return 1    
	fi
}
#======================================================================================
set_aliddns_conf(){
    local s0="$aliddns_conf"
	local v="";local r='"';local t="";local n=1;local j=0
	local tc=0;local s1="isipv4_domain";local s2="isipv6_domain";local s3="pppoe_ifname"
	local s4="cron_Time";local s5="cron_Time_type";local s6="islog";local s7="aliddns_AccessKeyId"
	local s8="aliddns_AccessKeySecret";local s9="routerddns_no";local s10="aliddns_name"
	local s11="aliddns_domain";local s12="aliddns_ttl";local s13="aliddns_type";local s14="aliddns_lan_mac"
    logs "1、中断所有输入操作请按ctrl+c, 跳过当前输入操作请按shift+#, 再按回车。" "" "rb" "w"
	logs "2、为避免错误，可以采用粘贴方式, 或者打开${s0}配置文件直接编辑。" "" "rb" "w"
	logs "3、${s10}, ${s11}, ${s12}, ${s13}和${s14}列表数必须都相等, 如本示例中的列表数都是3个。" "" "RB" "w"
	logs "4、关于${s14}：在IPV6中如想为终端设备进行域名解析, 则需要此终端设备MAC, 格式为ff:ff:ff:ff:ff:ff, 不需要为终端设备进行域名解析, 则设置为none。" "" "RB" "w"
	logs "5、在IPV4中${s14}要设置为none。" "" "rb" "w"
	logs "6、关于routerddns_no：选择哪个${s10}.${s11}为远程访问路由器域名地址, 其值为列表号。" "" "rb" "w"
	
	LTRIMFILE "$s0"	
	RTRIMFILE "$s0"	
	RMSPACEROWFILE "$s0"
	sed -i 's/  *=/=/g' "$s0"
	sed -i 's/=  */=/g' "$s0"
	
	#aliddns_AccessKeyId
	v=""
	while :;do
	    echo -en "${INFO}${YB_COLOR}阿里云key-${s7}[必须真实有效并通过阿里云审核]:${N_COLOR}"
	    read v
		v=$(echo "$v" | TRIMALL)
		if echo "$v" | grep -q '^[#]\+$';then
		    break
		elif isEmpty "$v";then
			echo -e "${INFO}${RB_COLOR}输入值不能为空值, 重输! ${N_COLOR}"
		elif echo "$v" | grep -q '^[a-zA-Z0-9]\+$';then
		    sed -i "s/^${s7}=.*/${s7}=${r}${v}${r}/g" "$s0"	
			break
		else
		    echo -e "${INFO}${RB_COLOR}非法字符, 重输! ${N_COLOR}"
		fi
    done
    #aliddns_AccessKeySecret
	v=""
	while :;do
	    echo -en "${INFO}${YB_COLOR}阿里云cret-${s8}[必须真实有效并通过阿里云审核]:${N_COLOR}"
	    read v
		v=$(echo "$v" | TRIMALL)
		if echo "$v" | grep -q '^[#]\+$';then
		    break
		elif isEmpty "$v";then
			echo -e "${INFO}${RB_COLOR}输入值不能为空值, 重输! ${N_COLOR}"
		elif echo "$v" | grep -q '^[a-zA-Z0-9]\+$';then
		    sed -i "s/^${s8}=.*/${s8}=${r}${v}${r}/g" "$s0"	
			break
		else
		    echo -e "${INFO}${RB_COLOR}非法字符, 重输! ${N_COLOR}"
		fi
    done		
	#islog
	v=""
	while :;do
	    echo -en "${INFO}${YB_COLOR}运行日志-${s6}[启用为1 禁用为0]:${N_COLOR}"
	    read v
		v=$(echo "$v" | TRIMALL)
		if echo "$v" | grep -q '^[#]\+$';then
		    break
		else
		    if iseq "$v" 0 || iseq "$v" 1;then
		        sed -i "s/^${s6}=.*/${s6}=${r}${v}${r}/g" "$s0"	
			    break
		    else
		        echo -e "${INFO}${RB_COLOR}输入值必须为0或1, 重输! ${N_COLOR}"
		    fi
		fi
    done	
	#isipv4_domain
	v=""
	while :;do
	    echo -en "${INFO}${YB_COLOR}IPV4-域名解析${s1}[启用为1 禁用为0]:${N_COLOR}"
	    read v
		v=$(echo "$v" | TRIMALL)
		if echo "$v" | grep -q '^[#]\+$';then
		    break
		else
		    if iseq "$v" 0 || iseq "$v" 1;then
		        sed -i "s/^${s1}=.*/${s1}=${r}${v}${r}/g" "$s0"	
			    break
		    else
		        echo -e "${INFO}${RB_COLOR}输入值必须为0或1, 重输! ${N_COLOR}"
		    fi
		fi
    done
    #isipv6_domain
	v=""
	while :;do
	    echo -en "${INFO}${YB_COLOR}IPV6-域名解析${s2}[启用为1 禁用为0]:${N_COLOR}"
	    read v
		v=$(echo "$v" | TRIMALL)
		if echo "$v" | grep -q '^[#]\+$';then
		    break
		else
		    if iseq "$v" 0 || iseq "$v" 1;then
		        sed -i "s/^${s2}=.*/${s2}=${r}${v}${r}/g" "$s0"	
			    break
		    else
		        echo -e "${INFO}${RB_COLOR}输入值必须为0或1, 重输! ${N_COLOR}"
		    fi
		fi
    done
	#pppoe_ifname
	v=""
    while :;do
	    echo -en "${INFO}${YB_COLOR}PPPOE接口-${s3}[一级路由单线为any, auto或wan0, 一级路由双线第一接口为wan0，第二接口为wan1, 二级路由为any]:${N_COLOR}"
	    read v
		v=$(echo "$v" | TRIMALL | set_lowercase)
		if echo "$v" | grep -q '^[#]\+$';then
		    break
		else
		    if iseq "$v" "any" || iseq "$v" "auto" || iseq "$v" "wan0" || iseq "$v" "wan1";then
		        sed -i "s/^${s3}=.*/${s3}=${r}${v}${r}/g" "$s0"	
			    break
		    else
		        echo -e "${INFO}${RB_COLOR}输入值必须为any, auto, wan0或wan1, 重输! ${N_COLOR}"
		    fi
		fi
    done
    #cron_Time_type
	v=""
    while :;do
	    echo -en "${INFO}${YB_COLOR}定时更新域名时间类型-${s5}[小时为hour, 分钟为min]:${N_COLOR}"
	    read v
		v=$(echo "$v" | TRIMALL | set_lowercase)
		if echo "$v" | grep -q '^[#]\+$';then
		    break
		else
		    if iseq "$v" "hour" || iseq "$v" "min";then
		        sed -i "s/^${s5}=.*/${s5}=${r}${v}${r}/g" "$s0"	
			    break
		    else
		        echo -e "${INFO}${RB_COLOR}输入值必须为hour或min, 重输! ${N_COLOR}"
		    fi
		fi
    done
	#cron_Time
	v=""
	t=$(cat $s0 | grep -w "${s5}" | RMSTRING "${s5}=" | RMSTRING '"' | RMSTRING "''" | TRIMALL)
    while :;do
	    echo -en "${INFO}${YB_COLOR}定时更新域名时间-${s4}[小时为1~23, 分钟为5~59]:${N_COLOR}"
	    read v
		v=$(echo "$v" | TRIMALL)
		if echo "$v" | grep -q '^[#]\+$';then
		    break
		else
		    if iseq "$t" "min";then
	            if check_number "$v" && isge "$v" 5 && isle "$v" 59;then
		            sed -i "s/^${s4}=.*/${s4}=${r}${v}${r}/g" "$s0"	
			        break
                else
		            echo -e "${INFO}${RB_COLOR}输入值必须为5~59, 重输! ${N_COLOR}"
                fi	
	        elif iseq "$t" "hour";then
	            if check_number "$v" && isge "$v" 1 && isle "$v" 23;then
		            sed -i "s/^${s4}=.*/${s4}=${r}${v}${r}/g" "$s0"	
			        break
                else
		            echo -e "${INFO}${RB_COLOR}输入值必须为1~23, 重输! ${N_COLOR}"
                fi
	        fi
        fi	
    done
	#aliddns_name
	v=""
	while :;do
	    echo -en "${INFO}${YB_COLOR}主机-${s10}[支持@和*, 多个主机以空格为分隔符, 例:@ * www]:${N_COLOR}"
	    read v
		v=$(echo "$v" | LTRIM | RTRIM | set_lowercase)
		if echo "$v" | grep -q '^[#]\+$';then
		    break
		elif isEmpty "$v";then
			echo -e "${INFO}${RB_COLOR}输入值不能为空值, 重输! ${N_COLOR}"
		elif echo "$v" | grep -q '^[a-zA-Z0-9@* ]\+$';then
		    sed -i "s/^${s10}=.*/${s10}=${r}${v}${r}/g" "$s0"	
			break
		else
		    echo -e "${INFO}${RB_COLOR}非法字符, 重输! ${N_COLOR}"
		fi
    done
	#aliddns_domain
	v=""
	while :;do
	    echo -en "${INFO}${YB_COLOR}域名-${s11}[多个域名以空格为分隔符, 例:abc.com abc.com abc.com]:${N_COLOR}"
	    read v
		v=$(echo "$v" | LTRIM | RTRIM | set_lowercase)
		if echo "$v" | grep -q '^[#]\+$';then
		    break
		elif isEmpty "$v";then
			echo -e "${INFO}${RB_COLOR}输入值不能为空值, 重输! ${N_COLOR}"
		else
		    j=1
		    for i in $v;do
				if echo -n "$i" | grep -v '\--' > /dev/null && echo -n "$i" | domainencode && echo -n "$i" | grep -q '^[a-zA-Z0-9].*[a-zA-Z0-9]$' > /dev/null;then  
				    j=0
				else
				    j=1
					break
				fi
			done 
		    if iseq "$j" 0;then
		        sed -i "s/^${s11}=.*/${s11}=${r}${v}${r}/g" "$s0"	
			    break
		    else
		        echo -e "${INFO}${RB_COLOR}非法字符, 重输! ${N_COLOR}"
		    fi
		fi
    done
	#aliddns_ttl
	v=""
	while :;do
	    echo -en "${INFO}${YB_COLOR}解析生效时间-${s12}[多个解析生效时间以空格为分隔符, 例:600 600 600]:${N_COLOR}"
	    read v
		v=$(echo "$v" | LTRIM | RTRIM)
		if echo "$v" | grep -q '^[#]\+$';then
		    break
		elif isEmpty "$v";then
			echo -e "${INFO}${RB_COLOR}输入值不能为空值, 重输! ${N_COLOR}"
		else
		    j=1
		    for i in $v;do
				if  check_number "$i" && isge "$i" 1;then
				    j=0
				else
				    j=1
					break
				fi
			done
			if iseq "$j" 0;then
		        sed -i "s/^${s12}=.*/${s12}=${r}${v}${r}/g" "$s0"	
			    break
		    else
		        echo -e "${INFO}${RB_COLOR}输入值必须为1以上的数字, 重输! ${N_COLOR}"
		    fi
		fi
    done
	#aliddns_type
	v=""
    while :;do
	    echo -en "${INFO}${YB_COLOR}域名记录类型-${s13}[IPV4为A, IPV6为AAAA, 多个域名记录类型以空格为分隔符, 例IPV4:A A A或IPV6:AAAA AAAA AAAA]:${N_COLOR}"
	    read v
		v=$(echo "$v" | LTRIM | RTRIM | set_uppercase)
		if echo "$v" | grep -q '^[#]\+$';then
		    break
		elif isEmpty "$v";then
			echo -e "${INFO}${RB_COLOR}输入值不能为空值, 重输! ${N_COLOR}"
		else
		    j=1
		    for i in $v;do
				if iseq "$i" "A";then
				    j=0
				elif iseq "$i" "AAAA";then
				    j=0
				else
				    j=1
					break
				fi
			done
		    if iseq "$j" 0;then
		        sed -i "s/^${s13}=.*/${s13}=${r}${v}${r}/g" "$s0"	
			    break
		    else
		        echo -e "${INFO}${RB_COLOR}输入值必须为A或AAAA, 重输! ${N_COLOR}"
		    fi
		fi
    done
	#aliddns_lan_mac
	v=""
    while :;do
	    echo -en "${INFO}${YB_COLOR}终端设备MAC-${s14}[IPV4为none, IPV6为none或终端设备MAC, 多个终端设备MAC以空格为分隔符, 例:none 78:da:c9:2b:de:1a none]:${N_COLOR}"
	    read v
		v=$(echo "$v" | LTRIM | RTRIM | set_lowercase)
		if echo "$v" | grep -q '^[#]\+$';then
		    break
		elif isEmpty "$v";then
			echo -e "${INFO}${RB_COLOR}输入值不能为空值, 重输! ${N_COLOR}"
		else
		    j=1
		    for i in $v;do
				if iseq "$i" "none";then 
				    j=0
				elif valid_mac "$i";then 
				    j=0
				else
                    j=1
					break				
				fi
			done
		    if iseq "$j" 0;then
		        sed -i "s/^${s14}=.*/${s14}=${r}${v}${r}/g" "$s0"	
			    break
		    else
		        echo -e "${INFO}${RB_COLOR}输入值必须为none或终端设备MAC, 重输! ${N_COLOR}"
		    fi
		fi
    done
	#routerddns_no
	v=""
	while :;do
	    echo -en "${INFO}${YB_COLOR}远程访问路由器列表号-${s9}[其值为${s10}等之列表号, 例:选择第1列输入1, 选择第3列输入3]:${N_COLOR}"
	    read v
		v=$(echo "$v" | TRIMALL)
		if echo "$v" | grep -q '^[#]\+$';then
		    break
		else
		    if check_number "$v" && isge "$v" 1;then
		        sed -i "s/^${s9}=.*/${s9}=${r}${v}${r}/g" "$s0"	
			    break
		    else
		        echo -e "${INFO}${RB_COLOR}输入值必须为1以上的数字, 重输! ${N_COLOR}"
		    fi
		fi
    done	
	#all check
    logs "开始对所有输入操作进行验证..." "" "rb" "w"
	local v4d=$(cat $s0     | grep -w $s1  | RMSTRING "$s1="  | RMSTRING '"' | RMSTRING "''" | TRIMALL)
    local v6d=$(cat $s0     | grep -w $s2  | RMSTRING "$s2="  | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	local pif=$(cat $s0     | grep -w $s3  | RMSTRING "$s3="  | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	local cnt=$(cat $s0     | grep -w $s4  | RMSTRING "$s4="  | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	local cnty=$(cat $s0    | grep -w $s5  | RMSTRING "$s5="  | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	local iog=$(cat $s0     | grep -w $s6  | RMSTRING "$s6="  | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	local key=$(cat $s0     | grep -w $s7  | RMSTRING "$s7="  | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	local cret=$(cat $s0    | grep -w $s8  | RMSTRING "$s8="  | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	local rno=$(cat $s0     | grep -w $s9  | RMSTRING "$s9="  | RMSTRING '"' | RMSTRING "''" | TRIMALL)
	local anl=$(cat $s0     | grep -w $s10 | RMSTRING "$s10=" | RMSTRING '"' | RMSTRING "''")
	local adl=$(cat $s0     | grep -w $s11 | RMSTRING "$s11=" | RMSTRING '"' | RMSTRING "''")
	local atl=$(cat $s0     | grep -w $s12 | RMSTRING "$s12=" | RMSTRING '"' | RMSTRING "''")
	local atpl=$(cat $s0    | grep -w $s13 | RMSTRING "$s13=" | RMSTRING '"' | RMSTRING "''")
	local aml=$(cat $s0     | grep -w $s14 | RMSTRING "$s14=" | RMSTRING '"' | RMSTRING "''")
	local n1=$(echo "$anl"  | ROWTOCOLUMN  | awk 'END{print NR}') 
	local n2=$(echo "$adl"  | ROWTOCOLUMN  | awk 'END{print NR}') 
	local n3=$(echo "$atl"  | ROWTOCOLUMN  | awk 'END{print NR}') 
	local n4=$(echo "$atpl" | ROWTOCOLUMN  | awk 'END{print NR}') 
	local n5=$(echo "$aml"  | ROWTOCOLUMN  | awk 'END{print NR}')
	if isNotEmpty "$n1" && check_number "$n1" && iseq "$n1" "$n2" && iseq "$n1" "$n3" && iseq "$n1" "$n4" && iseq "$n1" "$n5";then
	    tc="$n1"	
	    if isEmpty "$rno" || ! check_number "$rno" || isle "$rno" 0 || isgt "$rno" "$tc";then
	        logs "routerddns_no必须设置在1~${tc}之间, 重输!" "" "rb" "e"
	    else
			local rn=$(echo "$anl" | awk "{print $"$rno"}" | TRIMALL)
	        local rd=$(echo "$adl" | awk "{print $"$rno"}" | TRIMALL)
            logs "" "$LS"
			logs "运行日志-${s6}=${r}${iog}${r}"              "" "yb"
	        logs "IPV4域名解析-${s1}=${r}${v4d}${r}"          "" "yb"
	        logs "IPV6域名解析-${s2}=${r}${v6d}${r}"          "" "yb"
	        logs "PPPOE接口-${s3}=${r}${pif}${r}"             "" "yb"
		    logs "定时更新域名时间-${s4}=${r}${cnt}${r}"      "" "yb"
		    logs "定时更新域名时间类型-${s5}=${r}${cnty}${r}" "" "yb"
		    logs "阿里云key-${s7}=${r}${key}${r}"             "" "yb"
	        logs "阿里云cret-${s8}=${r}${cret}${r}"           "" "yb"
	        logs "远程访问路由器列表号-${s9}=${r}${rno}${r}"  "" "yb"
			logs "远程访问路由器地址=[${rn}.${rd}]"           "" "yb"	
			n=1
			until [ "$n" -gt "$tc" ];do 
			    local an=$(echo "$anl"  | awk "{print $"$n"}" | TRIMALL)
	            local ad=$(echo "$adl"  | awk "{print $"$n"}" | TRIMALL)
	            local at=$(echo "$atl"  | awk "{print $"$n"}" | TRIMALL)
	            local ay=$(echo "$atpl" | awk "{print $"$n"}" | TRIMALL)
	            local am=$(echo "$aml"  | awk "{print $"$n"}" | TRIMALL | set_lowercase)
				logs "第${n}列==========>"               "" "rl"
				logs "主机-${s10}=${r}${an}${r}"         "" "yb"
				logs "域名-${s11}=${r}${ad}${r}"         "" "yb"
				logs "记录类型-${s13}=${r}${ay}${r}"     "" "yb"
				logs "解析生效时间-${s12}=${r}${at}${r}" "" "yb"
				logs "终端设备MAC-${s14}=${r}${am}${r}"  "" "yb"
				logs "第${n}列<=========="               "" "rl"
				n=$(sadd $n 1)		
			done
			logs "" "$LS"
			logs "经过初步验证，所有输入操作看起来是正确的, 请认真核对!" "" "rb" "w"
			logs "10秒后, 脚本将自动运行, 请注意观察运行是否正常!" "" "rb" "w"
			set_scripts "a"
			go_sleep 10
			sh "$scripts_sh" "start_unlock"
			j=0
	    fi	
	else
	    logs "${s10}, ${s11}, ${s12}, ${s13}和${s14}列表数必须都相等, 重输!" "" "rb" "e"
        logs "${s10} 列表数=$n1" "" "yb"
		logs "${s11} 列表数=$n2" "" "yb"
		logs "${s12} 列表数=$n3" "" "yb"
		logs "${s13} 列表数=$n4" "" "yb"
		logs "${s14} 列表数=$n5" "" "yb"	
        j=1		
	fi
	return $j
}
#======================================================================================
get_Record_list() {
    local s1=$1;local s2=$2;local n=1
	isNotEmpty $s2 && n=$s2                                                        
    echo "$(echo -e $s1 | TRIMALL | awk -F '[' '{print $2}' | awk -F ']' '{print $1}' | awk -F '},' "{print $"$n"}" | RMSTRING '{' | RMSTRING '}')"
}
#======================================================================================
get_Record_value(){ 
   local s1=$1;local s2=$2
   echo "$(echo $s1 | TRIMALL | awk -F $s2 '{print $2}' | awk -F ',' '{print $1}' | RMSTRING '"' | RMSTRING '^:' | TRIMALL)" 
}
#======================================================================================
get_Record(){
    local Type="$aliddns_type";local jk=9;local n=0;local q="";local r=0;local j=0
	Record_RequestId="";Record_Ids="";Record_TotalCount=0;Record_Id="";Record_IP="";Record_name=""
	Record_domain="";Record_Status="";Record_type="";Record_Locked="";Record_ttl="";num_getRecord=1  
	if iseq "$isRUN" 1 || ! do_run_check;then
        do_cron "$ID_CRU" "a" "$cron_File" "month=* week=* day=* hour=* min=2" "min" "$scripts_sh" "update" 
		rm -f "$FL"
		exit 1
	fi
	until [ "$num_getRecord" -gt "$jk" ];do 
		if isNotEmpty "$aliddns_url_ok";then
		    aliddns_url="$aliddns_url_ok"
		else
		    n=$(($num_getRecord % 2))
			if iseq "$n" 1;then 
                aliddns_url="http://alidns.aliyuncs.com"
            else
                aliddns_url="https://alidns.aliyuncs.com"
            fi
		fi
		logs "$num_getRecord/$jk:Select this address[$aliddns_url] to link aliyun and Geting domain name Record, please wait..." "" "y" 
	    q=$(aliddns_subdomain_Records "$aliddns_name" "$aliddns_domain" "$Type") 
		
		if iseq "$ndebug" 2;then
		    logs "*********************************************************************************"
     		if iseq "$num_getRecord" 1;then
		        logs "aliyun domain name Record Query=$q" "" "yb"	
                q=""				
			else
			    logs "aliyun domain name Record Value=$q" "" "yb"
			fi 
			logs "*********************************************************************************"
		fi
		if aliddns_response_check "$q" >/dev/null 2>&1;then
		    Record_RequestId=$(get_Record_value $q "RequestId")     >/dev/null 2>&1
            Record_TotalCount=$(get_Record_value "$q" "TotalCount") >/dev/null 2>&1                                                                      
		    if isNotEmpty "$Record_RequestId" && isgt "$Record_TotalCount" 0;then
		        logs "$num_getRecord/$jk:Geting aliyun Record successfully[获取阿里云记录成功]"   "" "vl" "t"
				aliddns_url_ok="$aliddns_url"
				break
			else    
				#aliyun domain name Record is null value, with add
 		        return 0
	        fi   
        else
		    if isge "$num_getRecord" "$jk";then
		        logs "Failed to obtain aliyun domain name Record, Check whether your domain name has passed the audit," "" "ra" "e"
			    logs "aliddns_AccessKeyId and aliddns_AccessKeySecret are correct and valid." "" "ra" "e"
			    logs "获取阿里云域名记录失败, 检查您的域名是否通过审核," "" "ra" "e"
			    logs "aliddns-accesskeyid和aliddns-accesskeysecret是否正确有效。" "" "ra" "e" 
				rm -f "$FL"
			    exit 1
			fi
        fi
        num_getRecord=$(sadd $num_getRecord 1)		
	done
	
    until [ "$j" -eq "$Record_TotalCount" -o "$r" -eq 1 ];do 
		j=$(sadd $j 1)			
		s=$(get_Record_list "$q" "$j")                    >/dev/null 2>&1
		if iseq "$ndebug" 2;then
		    logs "*********************************************************************************"
		    logs "$s" "" "yb" 
			logs "*********************************************************************************"
		fi
		Record_Id=$(get_Record_value $s "RecordId")       >/dev/null 2>&1
		Record_IP=$(get_Record_value $s "Value")          >/dev/null 2>&1
		Record_type=$(get_Record_value $s "Type")         >/dev/null 2>&1		
		Record_name=$(get_Record_value $s "RR")           >/dev/null 2>&1
		Record_domain=$(get_Record_value $s "DomainName") >/dev/null 2>&1
        Record_Status=$(get_Record_value $s "Status")     >/dev/null 2>&1
        Record_Locked=$(get_Record_value $s "Locked")     >/dev/null 2>&1
        Record_ttl=$(get_Record_value $s "TTL")           >/dev/null 2>&1
	    Record_Line=$(get_Record_value $s "Line")         >/dev/null 2>&1
		Record_Priority=$(get_Record_value $s "Priority") >/dev/null 2>&1
		Record_Weight=$(get_Record_value $s "Weight")     >/dev/null 2>&1
		if isEmpty "$Record_Ids";then
			Record_Ids="$Record_Id"
        else
			Record_Ids="$Record_Ids $Record_Id"
        fi
        if iseq "$aliddns_type" "AAAA";then
	        logs "Record_ipv6_IP=[$Record_IP]" "" "ys"  
		elif iseq "$aliddns_type" "A";then
		    logs "Record_ipv4_IP=[$Record_IP]" "" "ys" 
		fi
		logs "Record_type=[$Record_type]"                 "" "y"			
        logs "Record_name=[$Record_name]"                 "" "y"	
		logs "Record_domain=[$Record_domain]"             "" "y"	
		logs "Record_Status=[$Record_Status]"             "" "y"
        logs "Record_Ids=[$Record_Ids]"                   "" "y"			
		if iseq "$ndebug" 2;then
            logs "Record_Locked=[$Record_Locked]"         "" "y"	
            logs "Record_ttl=[$Record_ttl]"               "" "y"
		    logs "Record_Line=[$Record_Line]"             "" "y"
		    logs "Record_Priority=[$Record_Priority]"     "" "y"
		    logs "Record_Weight=[$Record_Weight]"         "" "y"
		    logs "Record_TotalCount=[$Record_TotalCount]" "" "y"	
		    logs "Record_RecordCount=[$j]"                "" "y"	
			logs "Record_Id=[$Record_Id]"                 "" "y"
			logs "Record_RequestId=[$Record_RequestId]"   "" "y"	
        fi		
		if iseq "$j" "$Record_TotalCount";then
			r=1
		    break
		fi
	done
	if iseq "$isRUN" 1 || ! do_run_check;then
        do_cron "$ID_CRU" "a" "$cron_File"  "month=* week=* day=* hour=* min=2" "min" "$scripts_sh" "update" 
		rm -f "$FL"
		exit 1
	fi
    if iseq "$r" 1;then
        return 0
    else	
	    return 1
	fi
}
#======================================================================================
get_Records(){
    local q=$(aliddns_domain_Records "$1")
	if ! aliddns_response_check "$q" >/dev/null 2>&1;then
	    logs "aliddns_domain_Records Error, please check." "" "rb" "e"
		logs "$q" "" "r" "e"
	fi
}
#======================================================================================
get_domain_Info(){
    local q=$(aliddns_domain_Info "$1")
	if ! aliddns_response_check "$q" >/dev/null 2>&1;then
	    logs "aliddns_domain_Info Error, please check." "" "rb" "e"
		logs "$q" "" "rb" "e"
	fi
}
#======================================================================================
get_DescribeDomains(){
    local q=$(aliddns_DescribeDomains "$1")
	if ! aliddns_response_check "$q" >/dev/null 2>&1;then
	    logs "aliddns_DescribeDomains Error, please check." "" "rb" "e"
		logs "$q" "" "rb" "e"
	fi
}
#======================================================================================
set_syslogd(){
    isexists "syslogd" && "$existspath" -m 0 -S -O "/tmp/syslog.log" -s 256 -l 8
	nvram set log_level=8
    nvram set log_size=256
    nvram set message_loglevel=5
    nvram set console_loglevel=5
	nvram commit
}
#======================================================================================
set_ddns_show(){
    if iseq "$OS_TYPE" "merlin";then
        if iseq "$1" 1;then
	        nvram set ddns_enable_x=1
		    nvram set ddns_server_x="CUSTOM"
	        nvram set ddns_ipaddr="$3"
	        nvram set ddns_cache=1528160609,"$3"
            nvram set ddns_hostname_old="$2"
		    nvram set ddns_hostname_x_old="$2"
            nvram set ddns_hostname_x="$2"
	        nvram set ddns_status=1
		    nvram set le_enable=0
	    else
	        nvram set ddns_enable_x=0
        fi	
	    nvram commit
	fi
	return 0
}
#======================================================================================
set_ipv6_config(){
    if iseq "$OS_TYPE" "merlin" && isne "$(nvram get ipv6_service | tr 'A-Z' 'a-z')" "disabled";then
	    if [ -d /proc/sys/net/ipv6 ];then
		    #change
            echo 300  > /proc/sys/net/ipv6/neigh/br0/base_reachable_time      #30
            echo 300  > /proc/sys/net/ipv6/neigh/default/base_reachable_time  #30

		    #change
		    echo 60   > /proc/sys/net/ipv6/neigh/br0/gc_stale_time            #60
		    echo 60   > /proc/sys/net/ipv6/neigh/default/gc_stale_time        #60
		
		    echo 512  > /proc/sys/net/ipv6/neigh/default/gc_thresh1           #512
            echo 1024 > /proc/sys/net/ipv6/neigh/default/gc_thresh2           #1024
            echo 2048 > /proc/sys/net/ipv6/neigh/default/gc_thresh3           #2048
		    echo 0    > /proc/sys/net/ipv6/neigh/br0/locktime                 #0
		
            echo 4096 > /proc/sys/net/ipv6/route/max_size                     #4096
  
            echo 3    > /proc/sys/net/ipv6/conf/default/router_solicitations  #3
            echo 3    > /proc/sys/net/ipv6/conf/br0/router_solicitations      #3
		
		    #change
		    echo 60     > /proc/sys/net/ipv6/ip6frag_time                     #60
		    echo 262144 > /proc/sys/net/ipv6/ip6frag_high_thresh              #262144
		    echo 196608 > /proc/sys/net/ipv6/ip6frag_low_thresh               #196608
		    echo 600    > /proc/sys/net/ipv6/ip6frag_secret_interval          #600
		    echo 64     > /proc/sys/net/ipv6/mld_max_msf                      #64
		
            #enable ifconfig ipv6
		    echo 0      > /proc/sys/net/ipv6/conf/all/disable_ipv6
		fi
		nvram set ipv6_ns_drop=0
	    nvram set misc_ping_x=1
	    nvram commit
    fi
	return 0
}
#======================================================================================
aliddns_name_escape(){
    local s=$1;local r=""
    case ${s} in
        \*)
        r=%2A;;
        \@)
        r=%40;;
        *)
		r=${s}
    esac
	echo ${r}
}
#======================================================================================
aliddns_name_real(){
    local s1=$1;local s2=$2
    if iseq ${s1} '@' || isEmpty ${s1};then
        echo ${s2}
    else
        echo ${s1}.${s2}
    fi
}
#======================================================================================
aliddns_encode() {
    echo -n "$1" | urlencode
}
#======================================================================================
aliddns_domain_Timestamp(){
    #ISO8601 UTC:YYYY-MM-DDThh:mm:ssZ, eg:2015-01-09T12:00:00Z
	echo `date -u +"%Y-%m-%dT%H:%M:%SZ"`
}
#======================================================================================
aliddns_domain_Nonce(){
    local ui="/proc/sys/kernel/random/uuid"
	if [ -f "$ui" ];then
        echo $(cat $ui)
	else
		echo $(date -u +"%Y%m%d%H%M%S")
	fi
}
#======================================================================================
aliddns_response_check(){
    ###########################################################################
	#IF ERROR aliddns_response_check RETURN https://error-center.aliyun.com...
	###########################################################################
	isEmpty "$1" && return 1
    if isEmpty "$(echo $1 | set_lowercase | grep -o 'error-center')";then
	    return 0
	else
	    return 1
	fi
}
#======================================================================================
aliddns_domain_api(){
    local UR="";local US="";QU="";local HM="GET";
	local KS="${aliddns_AccessKeySecret}"
	local KI="${aliddns_AccessKeyId}"
	local SE=$(aliddns_encode '/')
	if iseq "$isRUN" 1 || ! do_run_check;then
        do_cron "$ID_CRU" "a" "$cron_File" "month=* week=* day=* hour=* min=2" "min" "$scripts_sh" "update" 
		rm -f "$FL"
		exit 1
	fi
	UR="${UR}AccessKeyId=${KI}"
	UR="${UR}${SP}Format=json"
	UR="${UR}${SP}SignatureNonce=$(aliddns_domain_Nonce)"
	UR="${UR}${SP}SignatureMethod=HMAC-SHA1"
	UR="${UR}${SP}SignatureVersion=1.0"
	UR="${UR}${SP}Timestamp=$(aliddns_encode $(aliddns_domain_Timestamp))"
	UR="${UR}${SP}Version=2015-01-09"
	UR="${UR}${SP}$1"
	UR=$(echo -n ${UR} | sed 's/\'"${SP}"'/\n/g' | $SORT | sed ':label; N; s/\n/\'"${SP}"'/g; b label')
	
	US="${HM}${SP}${SE}${SP}$(aliddns_encode ${UR})"
	US=$(echo -n ${US} | $OPENSSL dgst -sha1 -hmac ${KS}${SP} -binary | $OPENSSL base64)
	
	QU="${UR}${SP}Signature=$(aliddns_encode ${US})"
	QU="$(get_url_cmd ${aliddns_url}/?${QU})"

	if iseq "$ndebug" 2 && iseq "$num_getRecord" 1;then
	    echo "$($QU)"
	else
	    echo "$QU"
	   
	fi
}
#======================================================================================
aliddns_subdomain_Records(){
    #use:q=$(aliddns_subdomain_Records "$aliddns_name" "$aliddns_domain" "$Type")
	local UR="";local an="$(aliddns_name_escape "$1")";local sd="$an.$2"
    UR="${UR}Action=DescribeSubDomainRecords"
	UR="${UR}${SP}SubDomain=${sd}"
	UR="${UR}${SP}Type=$3"
	UR="${UR}${SP}TTL=${aliddns_ttl}"
	echo $(aliddns_domain_api ${UR})
}
#======================================================================================
aliddns_domain_update(){
    #use:q=$(aliddns_domain_update "$aliddns_name" "$wan_ipvx_IP" "$Record_Id" "$aliddns_type")
    local UR=""
    UR="${UR}Action=UpdateDomainRecord"
	UR="${UR}${SP}RR=$(aliddns_name_escape "$1")"
	#UR="${UR}${SP}Value=$2"
	UR="${UR}${SP}Value=$(aliddns_encode "$2")"
	UR="${UR}${SP}RecordId=$3"
	UR="${UR}${SP}Type=$4"
	UR="${UR}${SP}TTL=${aliddns_ttl}"	
	echo $(aliddns_domain_api ${UR})
}
#======================================================================================
aliddns_domain_add(){
    #use:q=$(aliddns_domain_add "$aliddns_name" "$aliddns_domain" "$wan_ipvx_IP" "$aliddns_type")
    local UR=""
    UR="${UR}Action=AddDomainRecord"
	UR="${UR}${SP}DomainName=$2"
	UR="${UR}${SP}RR=$(aliddns_name_escape "$1")"
	#UR="${UR}${SP}Value=$3"
	UR="${UR}${SP}Value=$(aliddns_encode "$3")"
	UR="${UR}${SP}Type=$4"
	UR="${UR}${SP}TTL=${aliddns_ttl}"
	echo $(aliddns_domain_api ${UR})
}
#======================================================================================
aliddns_domain_del(){
    #use:q=$(aliddns_domain_del "$i" "$aliddns_type")
    local UR=""
    UR="${UR}Action=DeleteDomainRecord"
	UR="${UR}${SP}RecordId=$1"
	UR="${UR}${SP}Type=$2"
	UR="${UR}${SP}TTL=${aliddns_ttl}"
	echo $(aliddns_domain_api ${UR})
}
#======================================================================================
aliddns_subdomain_del(){
    #use:q=$(aliddns_subdomain_del "$aliddns_name" "$aliddns_domain" "$aliddns_type")
	local UR="";local an="$(aliddns_name_escape "$1")";local sd="$an.$2"
    UR="${UR}Action=DeleteSubDomainRecords"
	UR="${UR}${SP}DomainName=$2"
	UR="${UR}${SP}Value=${sd}"
	UR="${UR}${SP}RR=$(aliddns_name_escape "$1")"
	UR="${UR}${SP}Type=$3"
	UR="${UR}${SP}TTL=${aliddns_ttl}"
	echo $(aliddns_domain_api ${UR})
}
#======================================================================================
aliddns_domain_Status(){
    #use:q=$(aliddns_domain_Status "$Record_Id" "$status" "$aliddns_type") 
    local UR=""
    UR="${UR}Action=SetDomainRecordStatus"
	UR="${UR}${SP}RR=$(aliddns_name_escape "$1")"
	UR="${UR}${SP}RecordId=$1"
	UR="${UR}${SP}Status=$2"
	UR="${UR}${SP}Type=$3"
	UR="${UR}${SP}TTL=${aliddns_ttl}"
	echo $(aliddns_domain_api ${UR})
}
#======================================================================================
aliddns_domain_Record_check(){
    #use:q=$(aliddns_domain_Record_check "$Record_name" "$Record_domain" "$wan_ipvx_IP" "$aliddns_type")
    #RR * has bug, use nslookup check
    local UR=""
    UR="${UR}Action=CheckDomainRecord"
	UR="${UR}${SP}DomainName=$2"
	UR="${UR}${SP}RR=$(aliddns_name_escape "$1")"
	#UR="${UR}${SP}Value=$3"
	UR="${UR}${SP}Value=$(aliddns_encode "$3")"
	UR="${UR}${SP}Type=$4"
	echo $(aliddns_domain_api ${UR})
}
#======================================================================================
aliddns_domain_Whois_Info(){
    #use:q=$(aliddns_domain_Whois_Info "$1")
    local UR=""
    UR="${UR}Action=DescribeDomainWhoisInfo"
	UR="${UR}${SP}DomainName=$1"
	echo $(aliddns_domain_api ${UR})
}
#======================================================================================
aliddns_domain_Records(){
    #use:s=$(aliddns_domain_Records "$aliddns_domain")
    local UR=""
    UR="${UR}Action=DescribeDomainRecords"
	UR="${UR}${SP}DomainName=$1"
	echo $(aliddns_domain_api ${UR})
}
#======================================================================================
aliddns_domain_Record_Info(){
    #user:s=$(aliddns_domain_Record_Info "$Record_Id" "$Record_type")
    local UR=""
    UR="${UR}Action=DescribeDomainRecordInfo"
	UR="${UR}${SP}RecordId=$1"
	UR="${UR}${SP}Type=$2"
	UR="${UR}${SP}TTL=${aliddns_ttl}"
	echo $(aliddns_domain_api ${UR})
}
#======================================================================================
aliddns_domain_Info(){
    #user:s=$(aliddns_domain_Info "$aliddns_domain")
    local UR=""
    UR="${UR}Action=DescribeDomainInfo"
	UR="${UR}${SP}DomainName=$1"
	echo $(aliddns_domain_api ${UR})
}
#======================================================================================
aliddns_DescribeDomains(){
    #user:s=$(aliddns_DescribeDomains "$aliddns_name")
    local UR=""	
    UR="${UR}Action=DescribeDomains"
	UR="${UR}${SP}KeyWord=$(aliddns_name_escape "$1")"
	echo $(aliddns_domain_api ${UR})
}
#======================================================================================
aliddns_AddDomain(){
    #user:s=$(aliddns_AddDomain "$aliddns_domain")
    local UR=""
    UR="${UR}Action=AddDomain"
	UR="${UR}${SP}DomainName=$1"
	echo $(aliddns_domain_api ${UR})
}
#======================================================================================
do_aliddns_domain_Record_check(){
    #not use
    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain] Use CheckDomainRecord Check." "" "y"
    isdnsExist="false"
	local q="";local s="";local c=""
    q=$(aliddns_domain_Record_check "$1" "$2" "$3" "$4")
	if ! aliddns_response_check "$q" >/dev/null 2>&1;then
	    logs "aliddns_domain_Record_check Error, please check." "" "rb" "e"
		logs "$q" "" "r" "e"
	fi
	
	isEmpty "$q" && return 1
	s=$(echo -e "$q" | sed 's/{//g' | sed 's/}//g')
	c=$(get_Record_value $s "IsExist") >/dev/null 2>&1
	isdnsExist=$(set_strlowercase "$c")
	if iseq "$isdnsExist" "true";then
	    return 0
	else
	    return 1
	fi
}
#======================================================================================
do_aliddns_domain_Whois_Info(){
    local r=0;local q=""
	isdnsWhois=0
	q=$(aliddns_domain_Whois_Info "$1")
	if ! aliddns_response_check "$q" >/dev/null 2>&1;then 
	    logs "aliddns_domain_Whois_Info Error, please check." "" "rb" "e"
		logs "$q" "" "rb" "e"
	fi
	isEmpty "$q" && return 1
	for i in "Pendingdelete" "redemption period" "Clienthold" "serverhold" "Inactive";do
	    if isNotEmpty "$(echo $q | grep -Eo $i)";then
		    r=1
            break			
		fi
	done
	if iseq "$r" 1;then
	    isdnsWhois=0
		return 1
	else
	    isdnsWhois=1
		return 0
	fi
}
#======================================================================================
do_subdomain_del(){
    #not use
	local q=$(aliddns_subdomain_del "$aliddns_name" "$aliddns_domain" "$aliddns_type") >/dev/null 2>&1 
	if ! aliddns_response_check "$q" >/dev/null 2>&1;then
	    logs "do_subdomain_del Error, please check." "" "rb" "e"
	fi
	isEmpty "$q" && return 1
    ! get_Record >/dev/null 2>&1 && return 1
	if isNotEmpty "$Record_Ids";then
	    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain] remove Failed." "" "rb" "e"
		goto_remove "$Count" 
		return 1
	else
		if do_router_ddns_check;then
		    [ -x "$aliddns_dcu" ] && "$aliddns_dcu" 0
		fi
		logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain] is does not exist or remove success." "" "gb" "t"
		return 0
	fi
}
#======================================================================================
do_Record_Only_check(){
	local n=0
	for i in $Record_Ids;do
		isNotEmpty "$i" && n=$(sadd $n 1)	
	done
	if isle "$n" 1;then
	    return 0
	else
		logs "check that there are $n Record on aliyun." "" "gb"
		logs "Record_Ids[$Record_Ids]"                   "" "gb"
		return 1
	fi
	
}
#======================================================================================
do_checkwanip(){
    if iseq "$aliddns_type" "AAAA" && iseq "$isipv6_domain" 0;then
		set_success 1 "$actions" "skiped"	
	    return 1
	elif iseq "$aliddns_type" "A" && iseq "$isipv4_domain" 0;then
		set_success 1 "$actions" "skiped"	
	    return 1
	fi
    if iseq "$aliddns_type" "A" || iseq "$aliddns_type" "AAAA";then
	    logs "Router wan ifname is[${wan_ifname}], wan is[wan${wan_no}], proto is[${wan_proto}]" "" "ys" "t" 
		if get_wan_ipv46;then
			do_aliddns_log "checkwanip" "success"
			set_success 1 "$actions" "success"	
		else
			do_aliddns_log "checkwanip" "failed"
			set_success 0 "$actions" "failed"	
		fi
	fi
}
#======================================================================================
do_check(){
    isdnsExist="false"

	if iseq "$aliddns_type" "AAAA" && iseq "$isipv6_domain" 0;then
		set_success 1 "$actions" "skiped"	
	    return 1
	elif iseq "$aliddns_type" "A" && iseq "$isipv4_domain" 0;then
		set_success 1 "$actions" "skiped"	
	    return 1
	fi
	
	if iseq "$aliddns_type" "AAAA";then
	    if iseq "$OS_TYPE" "merlin";then
		    if iseq "$isIPV6" 1;then
	            logs "Your Router ipv6 is disabled, skip." "" "yb" "t"
		        logs "$Count:failed..." "" "rb" "e"
		        set_ddns_show 0 "$(aliddns_name_real "$routerddns_name" "$routerddns_domain")" "$wan_ipvx_IP"
	            return 1
			fi
		elif iseq "$OS_TYPE" "padavan" || iseq "$OS_TYPE" "openwrt" || iseq "$OS_TYPE" "pandorabox";then 
		    if iseq "$isIPV6" 1;then
                logs "Your Router ipv6 is disabled, skip." "" "yb" "t"
		        logs "$Count:failed..." "" "rb" "e"
			    return 1
			fi
	    fi
	fi
	if iseq "$aliddns_type" "A" || iseq "$aliddns_type" "AAAA";then
	    
        logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain]Check has a Record on aliyun[检查阿里云是否有记录]" "" "y"
		! do_wan_ipaddr && return 1
	
	
	    if get_Record;then
		    isNotEmpty "$Record_Ids" && do_aliddns_log "getrecord" "success" "t" 
		else
		    return 1
		fi
	
	    if ! do_Record_Only_check;then
		    logs "Your Must remove the excess Record." "" "vb" "w"	
		    actions="remove"
		    return 0 
	    fi
	
	    if isEmpty "$Record_Id";then
		    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain][需要添加]" "" "y" "t"
            actions="added"		
	        return 0 
	    fi
		
        if isne "$(set_strlowercase "$Record_Status")" "enable";then
		    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain] status is DISABLE[状态禁用]" "" "y" "t"
		    return 1
	    fi		
	    if isne "$Record_IP" "$wan_ipvx_IP";then
		    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain]Needs to be updated[需要更新]" "" "ys"	"t"
		    actions="updated"
		    return 0 				
	    fi	
		
	    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain]Check the analysis is effect[检查解析已经生效]" "" "ys"
		
		do_nslookup_check "$aliddns_name" "$aliddns_domain" && isdnsExist="true"
		
		logs "[$nslookup_ipvx]=nslookup_$xIP" "" "gb"
	    logs "[$Record_IP]=Record_$xIP"       "" "gb"
		if isNotEmpty "$aliddns_lan_mac";then
     		logs "[$lan_ipvx_IP]=lan_$xIP"    "" "gb"
		else
		    logs "[$wan_ipvx_IP]=wan_$xIP"    "" "gb"
		fi
		   
	    if iseq "$Record_IP" "$wan_ipvx_IP" && iseq "$isdnsExist" "true";then
		    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain] The analysis has come into effect[解析已经生效]" "" "ys" "t"
		    if do_router_ddns_check;then
			    set_ddns_show 1 "$(aliddns_name_real "$routerddns_name" "$routerddns_domain")" "$wan_ipvx_IP"
		        [ -x "$aliddns_dcu" ] && "$aliddns_dcu" 1
		    fi
			do_aliddns_log "dnsExist" "success"
			set_success 1 "$actions" "success"	
	        return 1
	    fi
		
	    if iseq "$Record_IP" "$wan_ipvx_IP" && isne "$isdnsExist" "true";then
		    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain]The analysis takes 10 minutes to take effect[解析需要10分钟后才生效]" "" "ys" "w"
			do_aliddns_log "dnsExist" "wait"
			set_success 1 "$actions" "success"	
		    return 1 
	    fi
	else
	    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain]type error, Please check $aliddns_conf." "" "rb" "e"
		logs "$Count:failed..." "" "rb" "e"
	    return 1 
	fi
}
#======================================================================================
do_start(){
    local q="";local id=""
	if iseq "$aliddns_type" "AAAA" && iseq "$isipv6_domain" 0;then
		set_success 1 "$actions" "skiped"	
	    return 1
	elif iseq "$aliddns_type" "A" && iseq "$isipv4_domain" 0;then
		set_success 1 "$actions" "skiped"	
	    return 1
	fi
    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain] $actions operations will be performed..." "" "y"
	if iseq "$actions" "added";then
 		q=$(aliddns_domain_add "$aliddns_name" "$aliddns_domain" "$wan_ipvx_IP" "$aliddns_type") 
		if aliddns_response_check "$q" >/dev/null 2>&1;then
		    id=$(get_Record_value $q "RecordId") >/dev/null 2>&1
            isNotEmpty "$id" && do_Record_verification "$id" "$wan_ipvx_IP" && return 0
        fi		
    elif iseq "$actions" "updated";then
        q=$(aliddns_domain_update "$aliddns_name" "$wan_ipvx_IP" "$Record_Id" "$aliddns_type")  
		if aliddns_response_check "$q" >/dev/null 2>&1;then 
		    id=$(get_Record_value $q "RecordId") >/dev/null 2>&1
		    isNotEmpty "$id" && do_Record_verification "$id" "$wan_ipvx_IP" && return 0
		fi
    elif iseq "$actions" "remove";then
		goto_remove "$Count" && goto_start "$Count"	
	else
	    return 1
    fi
	return 1
}
#======================================================================================
do_status(){
    local id="";local st=""
    if iseq "$1" 0;then
	    Status="Disable"
	elif iseq "$1" 1;then
	    Status="Enable"
	fi
	if isEmpty "$Record_Id";then
	    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain] is does not exist or has been remove." "" "y"	
		return 1
	fi
	q=$(aliddns_domain_Status "$Record_Id" "$Status" "$aliddns_type") 
	if ! aliddns_response_check "$q" >/dev/null 2>&1;then
	    logs "aliddns_domain_Status Error, please check." "" "rb" "e"
	fi
	
	isEmpty "$q" && return 1
	id=$(get_Record_value $q "RecordId") >/dev/null 2>&1
	st=$(get_Record_value $q "Status")   >/dev/null 2>&1
	st=$(echo $st | set_uppercase)
	
	if iseq "$id" "$Record_Id";then
	    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain] status settings are success, and the current status is $st." "" "gb"
		do_aliddns_log "status" "$st"	
		set_success 1 "$actions" "success"	
		return 0
	else
	    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain] status setting Failed." "" "rb" "e"
		do_aliddns_log "status" "$st"
        set_success 0 "$actions" "failed"			
		return 1
	fi
}
#======================================================================================
do_remove(){
	! get_Record >/dev/null 2>&1 && return 1
	isEmpty "$Record_Ids" && logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain] is does not exist or has been remove." "" "gb" "t" && return 1
	for i in $Record_Ids;do
		q=$(aliddns_domain_del "$i" "$aliddns_type") 
		if ! aliddns_response_check "$q" >/dev/null 2>&1;then
	        logs "aliddns_domain_del Error, please check." "" "rb" "e"
			return 1
	    fi
		id=$(get_Record_value $q "RecordId") 	
		if iseq "$i" "$id";then					   
			if do_router_ddns_check;then
		        [ -x "$aliddns_dcu" ] && "$aliddns_dcu" 0
			fi
	        logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain]-[$i] remove success." "" "gb"
		else
			logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain]-[$i] remove Failed."  "" "rb" "e"
			goto_remove "$Count" 
            break					
		fi			
 	done
	return 0	
}
#======================================================================================
do_Record_verification(){
    #actions has added or updated
    local id="$1";local ip="$2";local r=0;local msg=""
	if [ "$actions" == "added" -a -n "$id" ] || [ "$actions" == "updated" -a -n "$id" -a "$id" == "$Record_Id" ];then
		logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain]-[$ip] $actions success." "" "ys" "t"
	    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain]analysis takes effect after about 10 minutes[解析大约10分钟后生效]" "" "ys" "w"
		if do_router_ddns_check;then
		    set_ddns_show 1 "$(aliddns_name_real "$routerddns_name" "$routerddns_domain")" "$wan_ipvx_IP"
		    [ -x "$aliddns_dcu" ] && "$aliddns_dcu" 1
		fi
        do_aliddns_log "$actions" "success"	
		do_aliddns_log "dnsExist" "wait"
        set_success 1 "$actions" "success"	
		return 0
	else
	    logs "$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain]-[$ip] $actions Failed, $actions operation again..." "" "rb" "e"
		logs "$Count:failed..." "" "rb" "e"
		[ -x "$aliddns_dcu" ] && "$aliddns_dcu" 0
		do_aliddns_log "$actions" "failed"	
        set_success 0 "$actions" "failed"	
        goto_start "$Count"		
		return 1			
	fi	
}
#======================================================================================
set_wake_host(){
   if iseq "$OS_TYPE" "merlin";then
        local r=0
	    local s=$(nvram get wollist)
        local l=$(nvram get lan_domain)
        local b=".$l"
        local a=$(echo "$(arp -a -i $ETH)" | grep -v 'incomplete' | awk '{print $1,$4}' | RMSTRING $b )
        local n=$(echo "$a" | awk 'END{print NR}')
        local i=1;local wollist='';local sl='<';local sr='>'
        isEmpty "$a" && return 0
        until [ "$i" -gt "$n" ];do    
	        m=$(echo "$a" | awk "NR==$i{print}" | awk '{print $2}' | TRIMALL | set_uppercase)
		    h=$(echo "$a" | awk "NR==$i{print}" | awk '{print $1}' | TRIMALL)
		    iseq "$h" "?" && h="client_$i"
	        if isNotEmpty "$h" && isNotEmpty "$m";then
	            wollist="$sl$h$sr$m$wollist"
			    iseq "$r" 0 && isEmpty "$(echo $s | grep -o $m)" && r=1
	        fi
		    i=$(sadd $i 1)	
        done
	    if isNotEmpty "$wollist" && iseq "$r" 1;then
	        nvram set wollist="$wollist"
		    nvram commit
	    fi
	fi
	return 0
}
#======================================================================================
goto_ping_wake(){
    iseq "$isipv6_domain" 0 && return 0
    isne "$OS_TYPE" "merlin" && return 0
    local ml="$1";local s0="$aliddns_conf";local s1="aliddns_lan_mac"
	local p4="";local p6="";local at="";local i=1;local r=0
	local sl='<';local sr='>';local h=""
	local wollist=$(nvram get wollist) 
	iseq "$isIPV6" 1 && return 0
	isEmpty "$ml" && ml=$(cat $s0 | grep -w $s1 | RMSTRING "$s1=" | RMSTRING '"' | RMSTRING "''" | set_lowercase)
	isEmpty "$ml" && return 0	
	for m in $ml;do
		if isne "$m" "none" && isEmpty "$(echo $wollist | grep -o $m)";then
		    h="client_$i"
		    wollist="$sl$h$sr$m$wollist"
		fi
		if isne "$m" "none";then
		    p4=$(echo "$($IP2 -4 neigh show dev $ETH)" | set_lowercase | grep -w $m | grep -v '^169'  | awk '{print $1}' | tail -n1 | awk '{print $NF}')
		    p6=$(echo "$($IP2 -6 neigh show dev $ETH)" | set_lowercase | grep -w $m | grep -v '^fe80' | awk '{print $1}' | tail -n1 | awk '{print $NF}')
	        at=$(echo "$($IP2 -6 neigh show dev $ETH)" | set_lowercase | grep -w $m | grep -v '^fe80' | awk '{print $4}' | tail -n1 | awk '{print $NF}')
		    isEmpty "$p4" && isEmpty "$p6" && break
		    valid_ipv4 "$p4" && ! valid_ipv6 "$p6" && r=1 && break
		    valid_ipv4 "$p4" && valid_ipv6 "$p6" && isNotEmpty "$at" && r=2 && break
		fi
		i=$(sadd $i 1) 	
		
	done
	if isNotEmpty "$wollist";then
	    nvram set wollist="$wollist"
		nvram commit
	fi
	if iseq "$r" 1;then
	    logs "" "$LS"
	    logs "attempt to activate client host[$p4]-[$m]" "" "y" "t"
	    do_ping4 "$p4" 3 3 >/dev/null 2>&1      
		do_ether_wake "$m" "$ETH" >/dev/null 2>&1
		logs "" "$LS"
		return 0
	elif iseq "$r" 2;then
	    logs "" "$LS" 
	    logs "activate client host[$p6]-[$m]-[$at]" "" "y" "t"
		do_ping4 "$p4" 3 3 >/dev/null 2>&1      
		do_ether_wake "$m" "$ETH" >/dev/null 2>&1
		logs "" "$LS"
		return 0
	fi
	return 0
}
#======================================================================================
goto_check(){
    issuccess="";isfailed="";rm -rf "$aliddns_msg" 
	currtimer=$(date +%s)
	if isEmpty "$1" || iseq "$1" 0 || ! isNumber "$1";then
	    Count=1
	    until [ "$Count" -gt "$aliddns_TotalCount" ];do  
		    logs "$Count:going..." "" "rb"	
		    get_aliddns_conf "$Count" && do_check 
			Count=$(sadd $Count 1)	
	    done
        return 0  
	elif isNumber "$1";then
	    if islt "$1" 1 || isgt "$1" "$aliddns_TotalCount";then
	        logs "please enter a specific value is 0 or 1~$aliddns_TotalCount." "" "rb" "e" 
		    return 1
	    fi
	    Count="$1"
		logs "$Count:going..." "" "rb"	
	    get_aliddns_conf "$Count" && do_check
	    return 0
	else
	    logs "please enter a specific value is 0 or 1~$aliddns_TotalCount." "" "rb" "e" 
	    return 1
	fi
}
#======================================================================================
goto_start(){
    issuccess="";isfailed="";rm -rf "$aliddns_msg" 
	currtimer=$(date +%s)
	if isEmpty "$1" || iseq "$1" 0 || ! isNumber "$1";then
	    Count=1
	    until [ "$Count" -gt "$aliddns_TotalCount" ];do  
		    logs "$Count:going..." "" "rb"	
		    get_aliddns_conf "$Count" && do_check && do_start
			Count=$(sadd $Count 1)	
	    done
		return 0
	elif isNumber "$1";then
	    if islt "$1" 1 || isgt "$1" "$aliddns_TotalCount";then
	        logs "please enter a specific value is 0 or 1~$aliddns_TotalCount." "" "rb" "e" 
		    return 1
	    fi
		Count="$1"
		logs "$Count:going..." "" "rb"	
	    get_aliddns_conf "$Count" && do_check && do_start
		return 0
	else
	    logs "please enter a specific value is 0 or 1~$aliddns_TotalCount." "" "rb" "e" 
		return 1
	fi
}
#======================================================================================
goto_again(){
    local jc=3;local again_num=0;local lCount="";local p4=""
	currtimer=$(date +%s)
	if [ ! -f "$isfailed_again" ] || [ ! -f "$isfailed_again_num" ];then
	    logs "No processable domain name resolution[没有可处理的域名解析]" "" "gb" "w"
	    return 1
	fi
	again_num=$(cat "$isfailed_again_num" | grep -w "again_num" | RMSTRING "again_num=" | TRIM)
	lCount=$(cat "$isfailed_again"        | grep -w "lCount"    | RMSTRING "lCount="    | TRIM)
	if isEmpty "$lCount" || isEmpty "$again_num" || ! check_number "$again_num";then
	    logs "No processable domain name resolution[没有可处理的域名解析]" "" "gb" "w"
	    rm -rf "$isfailed_again_num" >/dev/null 2>&1
	    rm -rf "$isfailed_again"     >/dev/null 2>&1
		do_realupdate "a" "" "$1"
		logs "" "$LS"
	    return 1 
	fi
	if isge "$again_num" "$jc" ;then
		logs "Unable to handle domain name resolution, please check[无法处理的域名解析, 请检查]" "" "gb" "w"
		for c in $lCount;do
			get_aliddns_conf "$c"
			m="$c:[$aliddns_type]-[$aliddns_name.$aliddns_domain]$1 $again_num/$jc for failed operation"
		    logs "$m" "" "gb" 
		done
		rm -rf "$isfailed_again_num" >/dev/null 2>&1
	    rm -rf "$isfailed_again"     >/dev/null 2>&1
		do_realupdate "a" "" "$1"
		logs "" "$LS"
		return 1
	fi
	for c in $lCount;do
		get_aliddns_conf "$c"
		if isEmpty "$aliddns_lan_mac";then
			goto_start $c
		else
		    p4=`echo "$($IP2 -4 neigh show dev $ETH)" | set_lowercase | grep -w $aliddns_lan_mac | grep -v '^169' | awk '{print $1}'`
			if valid_mac "$aliddns_lan_mac" && isNotEmpty "$p4" && do_ping4 "$p4" 3 3 >/dev/null 2>&1;then
		        goto_start $c
			else
				logs "[$aliddns_lan_mac]client is not active and unable to resolve domain name[客户端不在活跃状态, 无法进行域名解析]" "" "yb" "w" 
				#********************
				isfailed="$lCount"
				#********************
 		    fi
		fi
	done
	show_success  "$1 $again_num/$jc"
	do_realupdate "a" "$isfailed" "$1"
	return 0
}
#======================================================================================
goto_checkwanip(){
    issuccess="";isfailed="";rm -rf "$aliddns_msg" 
	currtimer=$(date +%s)
    if isNumber "$1";then
	    if isgt "$1" 0 && isle "$1" "$aliddns_TotalCount";then
	        Count="$1"
			logs "$Count:going..." "" "rb"	
	        get_aliddns_conf "$Count" && do_checkwanip
	        return 0
		fi
	else
	    Count=1
	    until [ "$Count" -gt "$aliddns_TotalCount" ];do  
		    logs "$Count:going..." "" "rb"	
		    get_aliddns_conf "$Count" && do_checkwanip 
			Count=$(sadd $Count 1)	
	    done
        return 0 
	fi
	return 1 
}
#======================================================================================
goto_status(){
    local ct=0
    issuccess="";isfailed="";rm -rf "$aliddns_msg" 
	currtimer=$(date +%s)
	if isEmpty "$1" || isEmpty "$2";then
	    logs "The parameters are wrong and the correct are Three parameters, exit." "" "rb" "e" 
		return 1 
	fi
	if ! isNumber "$1" || islt "$1" 0 || isgt "$1" "$aliddns_TotalCount";then
        logs "please enter a specific value is 0 or 1~$aliddns_TotalCount, exit." "" "rb" "e" 
		return 1
    fi
    if iseq "$2" 0 || iseq "$2" 1;then 
	    ct=1
	else
	    logs "please enter a specific value is 0 or 1, exit." "" "rb" "e"
		return 1
	fi
	if isgt "$1" 0 && isle "$1" "$aliddns_TotalCount";then
	    Count="$1"
		logs "$Count:going..." "" "rb"
	    get_aliddns_conf "$Count" && get_Record && do_Record_Only_check && do_status "$2"
		return 0
	elif iseq "$1" 0;then		
	    Count=1
	    until [ "$Count" -gt "$aliddns_TotalCount" ];do  
			logs "$Count:going..." "" "rb"
		    get_aliddns_conf "$Count" && get_Record && do_Record_Only_check && do_status "$2"
			Count=$(sadd $Count 1)	
	    done
		return 0
	fi	
}
#======================================================================================
goto_remove(){
    actions="remove";issuccess="";isfailed="";rm -rf "$aliddns_msg" 
	currtimer=$(date +%s)
	local res=0
    if ! isNumber "$1" || isEmpty "$1" || islt "$1" 0 || isgt "$1" "$aliddns_TotalCount";then
	    logs "please enter a specific value is 0 or 1~$aliddns_TotalCount." "" "rb" "e" 
		return 1
	fi
    if iseq "$1" 0;then
	    #remove all
		Count=1
	    until [ "$Count" -gt "$aliddns_TotalCount" ];do  
			logs "$Count:going..." "" "rb"	
		    if get_aliddns_conf "$Count";then
				if do_remove;then
				    do_aliddns_log "$actions" "success"
                    set_success 1 "$actions" "success"					
			    else
					do_aliddns_log "$actions" "failed"
					set_success 1 "$actions" "failed"
				fi
			fi
			Count=$(sadd $Count 1)	
	    done
		return 0
	elif isgt "$1" 0 && isle "$1" "$aliddns_TotalCount";then
	    #remove one
	    Count=1
	    until [ "$Count" -gt "$aliddns_TotalCount" ];do  
		    iseq "$1" "$Count" && res=1 && break 
			Count=$(sadd $Count 1)	
	    done
		if iseq "$res" 1;then
			logs "$Count:going..." "" "rb"	
			if get_aliddns_conf "$Count";then
			    if do_remove;then
				    do_aliddns_log "$actions" "success"	
                    set_success 1 "$actions" "success"					
			    else
					do_aliddns_log "$actions" "failed"
					set_success 1 "$actions" "failed"
			    fi
			fi
		fi
		return 0
	else
		return 1
	fi
}
#======================================================================================
find_wan_info(){
    local prefixes=$1;local primary="0";local prefix="";local wans_mode=""
	if iseq "$OS_TYPE" "merlin";then
	    wans_mode=$(nvram get wans_mode)
        wan_ifname="";wan_no=0;wan_proto=""
        if iseq "$wans_mode" "lb" 2>&1;then
	        for prefix in $prefixes;do
		        proto=$(nvram get ${prefix}proto)
			    wan_proto="$proto"
		        if [ "$proto" == "pppoe" -o "$proto" == "pptp" -o "$proto" == "l2tp" ];then
			        wan_ifname=$(nvram get ${prefix}pppoe_ifname)
		        else
			        wan_ifname=$(nvram get ${prefix}wan_ifname)
		        fi
	        done
        else
	        for prefix in $prefixes;do
		        primary=$(nvram get ${prefix}primary)
		        iseq "$primary" "1" 2>&1 && break
	        done
	        if iseq "$primary" "1" 2>&1;then
	            proto=$(nvram get ${prefix}proto)
		        wan_proto="$proto"
	            if [ "$proto" == "pppoe" -o "$proto" == "pptp" -o "$proto" == "l2tp" ];then
		            wan_ifname=$(nvram get ${prefix}pppoe_ifname)
	            else
		            wan_ifname=$(nvram get ${prefix}wan_ifname)
	            fi
		    fi  
        fi
		wan_no=$(echo $prefix | sed 's/^wan//' | sed 's/_//' 2>&1) 
		iseq "$pppoe_ifname" "any" 2>&1 && return 0
		if [ "$proto" == "pppoe" -o "$proto" == "pptp" -o "$proto" == "l2tp" ];then
	        isNotEmpty "$wan_ifname" && check_number "$wan_no" && isNotEmpty "$wan_no" && isNotEmpty "$wan_proto" && return 0  
	    fi
	elif iseq "$OS_TYPE" "padavan";then
	    proto=$(nvram get wan_proto)
	    wan_proto="$proto"
		wan_ifname="ppp0"
		return 0
	elif iseq "$OS_TYPE" "pandorabox" || iseq "$OS_TYPE" "openwrt";then
	   local p="";local u=""
	   for w in wan wan6;do
		    {
		        p=$(uci get network.${w}.proto) 
			    u=$(uci get network.${w}.username)
			} 2>/dev/null
            if [ "$p" == "pppoe" -a -n "$u" ];then	
			    proto="$p"
                wan_proto="$proto"
				wan_ifname="pppoe-${w}"
				if iseq "$w" "wan";then
				    wan_no=""
				elif iseq "$w" "wan";then
				    wan_no="6"
				fi
                break
		    fi
		done
	    #proto=$(uci -P /var/state get network.wan.proto)
	    #wan_proto="$proto"
		#wan_ifname=$(uci -P /var/state get network.wan.ifname)
		#wan_no=""
		return 0
	fi
	return 1
}
#======================================================================================
get_wan_info(){
    local r=1;local i=1;local n=10
    until [ "$i" -gt "$n" ];do    
	    if iseq "$pppoe_ifname" "auto" || iseq "$pppoe_ifname" "any";then
		    find_wan_info "wan0_ wan1_" && r=0 && break
	    elif iseq "$pppoe_ifname" "wan0";then
		    find_wan_info "wan0_" && r=0 && break
	    elif iseq "$pppoe_ifname" "wan1";then
		    find_wan_info "wan1_" && r=0 && break
	    fi
		i=$(sadd $i 1)	
	    sleep 1
	done
	if iseq "$r" 0;then
	    logs "Router wan ifname is[${wan_ifname}], wan is[wan${wan_no}], proto is[${wan_proto}]" "" "ys" "t" 
	    return 0
	else
	    logs "Router wan ifname is[${wan_ifname}], wan is[wan${wan_no}], proto is[${wan_proto}], wan is incorrect, please check." "" "rl" "w" 
		return 1
	fi
}
#======================================================================================
get_lan_ipv46(){
    local m="";local e;local n=1;local p4;local p6;local at
	lan_ipvx_IP="";lan_ipv4_IP="";lan_ipv6_IP=""
    isEmpty "$1" || isEmpty "$2" && return 1
    m=$(echo $1 | set_lowercase);e="$2"
	until [ "$n" -gt 3 ];do 
	    p4=$(echo "$($IP2 -4 neigh show dev $e)" | set_lowercase | grep -w $m | grep -v '^169'  | awk '{print $1}' | tail -n1 | awk '{print $NF}')
		p6=$(echo "$($IP2 -6 neigh show dev $e)" | set_lowercase | grep -w $m | grep -v '^fe80' | awk '{print $1}' | tail -n1 | awk '{print $NF}')
		at=$(echo "$($IP2 -6 neigh show dev $e)" | set_lowercase | grep -w $m | grep -v '^fe80' | awk '{print $4}' | tail -n1 | awk '{print $NF}')
		valid_ipv4 "$p4" && lan_ipv4_IP="$p4" 
		valid_ipv6 "$p6" && lan_ipv6_IP="$p6"
	    isNotEmpty "$lan_ipv4_IP" && isNotEmpty "$lan_ipv6_IP" && lan_ipvx_IP="$lan_ipv6_IP" && break
		n=$(sadd $n 1)	
	done
	if isNotEmpty "$lan_ipvx_IP";then
	    logs "[$lan_ipvx_IP]The lan_$xIP selected from lan macaddress[$m]-[$at]" "" "y"
	    return 0
	else
		return 1
	fi
}
#======================================================================================
get_wan_ipv46(){
    xIP="ipv4_IP";xan_ipvx_IP="";wan_ipv4_IP="";wan_ipv6_IP="";wan_ipvx_IP="";lan_ipv6_IP="";lan_ipvx_IP=""
	local k="-4";local r=1;local wp="";local IP_I="";local IP_E="";local pl=""
	iseq "$aliddns_type" "AAAA" && k="-6" && xIP="ipv6_IP" && xan_ipvx_IP="wan_$xIP"
	if iseq "$isRUN" 1 || ! do_run_check;then
        do_cron "$ID_CRU" "a" "$cron_File" "month=* week=* day=* hour=* min=2" "min" "$scripts_sh" "update" 
		rm -f "$FL"
		exit 1
	fi
	#get internal Public IP
    if iseq "$wan_ifname" "";then
	    pl=$($IP2 $k addr show                 | sed -n '/inet/{s!.*inet6* !!;s!/.*!!p}' | sed 's/peer.*//' | grep -v '^fe80')
	else
	    pl=$($IP2 $k addr show dev $wan_ifname | sed -n '/inet/{s!.*inet6* !!;s!/.*!!p}' | sed 's/peer.*//' | grep -v '^fe80') 
	fi
	for p in $pl;do
	    wp=$(echo $p | TRIMALL)	
	    if iseq "$aliddns_type" "AAAA";then
		    isNotEmpty "$wp" && public_ipv6_check "$wp" && IP_I="$wp" && break  
	    elif iseq "$aliddns_type" "A";then
            isNotEmpty "$wp" && public_ipv4_check "$wp" && IP_I="$wp" && break  
		fi	 
	done
	#get external Public IP
	if iseq "$aliddns_type" "AAAA";then  
		IP_E="$externalIP6"		
	elif iseq "$aliddns_type" "A";then	
		IP_E="$externalIP4"	
	fi
	if isNotEmpty "$IP_I" || isNotEmpty "$IP_E";then
	    logs "[$IP_E]The IP obtained from router external" "" "y"
	    logs "[$IP_I]The IP obtained from router internal" "" "y" 
	fi
	if [ "$proto" == "pppoe" -o "$proto" == "pptp" -o "$proto" == "l2tp" ];then
	    #First level router
	    isFirst_level_router=1
		if iseq "$IP_I" "$IP_E" && isNotEmpty "$IP_I" && isNotEmpty "$IP_E";then    
			#Public network
		    isPublic_network=1
			wan_ipvx_IP="$IP_E"
			r=0
		else
			#not Public network
			isPublic_network=0
			if isNotEmpty "$IP_E";then
			    wan_ipvx_IP="$IP_E"
			elif isNotEmpty "$IP_I";then
			    wan_ipvx_IP="$IP_I"
			fi
			r=0
		fi
    else
		#Second level router 
		#not Public network
		isFirst_level_router=0
		isPublic_network=0
		
		if isNotEmpty "$IP_E";then
			wan_ipvx_IP="$IP_E"
		elif isNotEmpty "$IP_I";then
			wan_ipvx_IP="$IP_I"
		fi
		r=0
	fi
	if iseq "$aliddns_type" "AAAA";then
	    wan_ipv6_IP="$wan_ipvx_IP"
	elif iseq "$aliddns_type" "A";then
	    wan_ipv4_IP="$wan_ipvx_IP"
	fi
	return "$r"
}
#======================================================================================
do_wan_ipaddr(){
	logs "Router wan ifname is[${wan_ifname}], wan is[wan${wan_no}], proto is[${wan_proto}]" "" "ys" "t" 
	if iseq "$aliddns_type" "AAAA";then
	    logs "Geting wan_ipv6_IP, Please wait..." "" "y" 
	elif iseq "$aliddns_type" "A";then
		logs "Geting wan_ipv4_IP, Please wait..." "" "y" 
	fi
	
	if get_wan_ipv46;then
		if iseq "$aliddns_type" "AAAA";then
	        if isNotEmpty "$aliddns_lan_mac";then
		        if ! get_lan_ipv46 "$aliddns_lan_mac" "$ETH";then
				    logs "[$aliddns_lan_mac]client is not active, so it cannot get IPv6 IP, skip[客户端不在活跃状态, 因此无法获取IPv6 IP]" "" "gb" "t"
					set_success 0 "$actions" "failed"
					return 1					
				fi
				
			    wan_ipvx_IP="$lan_ipv6_IP"
		        xan_ipvx_IP="lan_$xIP"
		    else
		        wan_ipvx_IP="$wan_ipv6_IP"
		        xan_ipvx_IP="wan_$xIP"
		    fi
	    fi
		
		do_aliddns_log "getwanip" "success"
		
		if iseq "$isFirst_level_router" 1;then
		    logs "Your router is First level[一级路由]" "" "vl"
		else
		    logs "Your router is Second level[二级路由]" "" "vl"
		fi
	    if iseq "$isPublic_network" 1;then
		    #Public network	
            if iseq "$wan_no" 0 || iseq "$wan_no" 1;then
		       iseq "$OS_TYPE" "merlin" && nvram set "wan${wan_no}_ipaddr"="$wan_ipvx_IP"
		    fi			
	        logs "The $xan_ipvx_IP[$wan_ipvx_IP] is public IP, and definitely Your complete possession[公网IP并独占]" "" "vl" "t"
	        return 0
		else
		    #Private network
			if iseq "$aliddns_type" "AAAA";then
			    if iseq "$isipv6_domain" 1;then
			        #domain analysis
	                logs "The $xan_ipvx_IP[$wan_ipvx_IP] is public IP, and uncertainty Your complete possession[公网IP非独占]" "" "vl" "t"
	                return 0
			    else
			        #not domain analysis
			        logs "You don't have to do domain analysis on $xan_ipvx_IP[$wan_ipvx_IP], skip." "" "vl" "t"
			        return 1
			    fi
			elif iseq "$aliddns_type" "A";then
			    if iseq "$isipv4_domain" 1;then
			        #domain analysis
	                logs "The $xan_ipvx_IP[$wan_ipvx_IP] is public IP, and uncertainty Your complete possession[公网IP非独占]" "" "vl" "t"
	                return 0
			    else
			        #not domain analysis
			        logs "You don't have to do domain analysis on $xan_ipvx_IP[$wan_ipvx_IP], skip." "" "vl" "t"
			        return 1
			    fi
			fi
		fi
	else
	    do_aliddns_log "getwanip" "failed"
		set_success 0 "$actions" "failed"
	    if iseq "$aliddns_type" "AAAA";then
		    if isNotEmpty "$aliddns_lan_mac";then
			    logs "[$aliddns_lan_mac]client is not active, so it cannot get IPv6 IP, skip[客户端不在活跃状态, 因此无法获取IPv6 IP]" "" "yb" "t"
			else
			    logs "Your router IPV6 IP cannot be obtained, skip." "" "yb" "w"
			fi
		elif iseq "$aliddns_type" "A";then
		    logs "Your router IPV4 IP is empty value or is private ip, skip." "" "yb" "w"
		fi
		return 1
	fi
}
#======================================================================================
do_speed_dns(){
    local t="";local r="";local s=",";local PING4=`which ping`
	if [ -z "$PING4" ];then
	    echo "1.1.1.1"
	else
	    for p in $1;do   
	        t=$($PING4 -4 -c 1 -W 5 -w 5 $p | tr 'A-Z' 'a-z' | grep -w 'time' | awk '{print $7}' | sed "s/time=//" 2>&1 | awk -F '.' '{print $1}')
			if [ $? -eq 0 ] && [ "$t" -ge 0 2>/dev/null ];then
			    if [ -z "$r" ];then
			        r="$t $p"
			    else
			        r="${r}${s}${t} ${p}"
			    fi
			fi
		done
		if [ -z "$SORT" ];then
		    r=$(echo $r | sed 's/,/\n/g' | awk "NR==1{print}" | awk '{print $2}')
		else
		    if iseq "$OS_TYPE" "merlin";then
			    r=$(echo $r | sed 's/,/\n/g' | $SORT -g -k1 -t ' ' | awk '{print $2}' | awk "NR==1{print}")
			else
			    r=$(echo $r | sed 's/,/\n/g' | $SORT -n | awk "NR==1{print}" | awk '{print $2}')
			fi
		fi
		if [ -n "$r" ];then
		    echo "$r"
		else
		    echo "1.1.1.1"
		fi
	fi
}
#======================================================================================
do_nslookup_check(){
	local name="$1";local n="";local domain="$2";local SERVER="$3";local ip="";local r=1;local HOST=$(aliddns_name_real "$name" "$domain")
	nslookup_ipvx="";isdnsExist="false"
	if iseq "$isRUN" 1 || ! do_run_check;then
        do_cron "$ID_CRU" "a" "$cron_File" "month=* week=* day=* hour=* min=2" "min" "$scripts_sh" "update"
		rm -f "$FL"
		exit 1
	fi
	logs "$Count:[$aliddns_type]-[$name"."$domain]-public_dns[$nslookup_dns] Use nslookup check." "" "vl"	
	logs "Getting the parsed IP address from nslookup can take a long time. Please wait patiently..." "" "vl" "w" 
	logs "从nslookup获取解析的IP地址，时间可能很长，请耐心等待..." "" "vl" "w" 
	n=$(do_nslookup "$HOST" "$nslookup_dns")
	for ip in $n;do
		if isNotEmpty "$ip" && isne "$ip" "$nslookup_dns";then
		    iseq "$aliddns_type" "A"    && public_ipv4_check "$ip" && iseq "$ip" "$wan_ipvx_IP" && nslookup_ipvx="$ip" && r=0 && break 
            iseq "$aliddns_type" "AAAA" && public_ipv6_check "$ip" && iseq "$ip" "$wan_ipvx_IP" && nslookup_ipvx="$ip" && r=0 && break  
		fi
	done
	
	return $r
}
#======================================================================================
do_router_ddns_check(){
    if iseq "$routerddns_name" "$aliddns_name" && iseq "$routerddns_domain" "$aliddns_domain";then
        return 0
    else
        return 1
    fi		
}
#======================================================================================
set_cron(){
    if iseq "$1" "a";then
		if isNotEmpty "$2";then
		    #isfailed
		    #start|restart|update|add
		    #Retry every 2 minutes
			if [ "$3" == "start" -o "$3" == "restart" -o "$3" == "update" -o "$3" == "add" ];then
                do_cron "$ID_CRU" "a" "$cron_File" "month=* week=* day=* hour=* min=2" "min" "$scripts_sh" "again" 
			fi
		else
		    #issuccess
		    #Retry every cron_Time
			if iseq "$cron_Time_type" "hour";then
		        do_cron "$ID_CRU" "a" "$cron_File" "month=* week=* day=* hour=$cron_Time min=0" "hour" "$scripts_sh" "update" 
			elif iseq "$cron_Time_type" "min";then
			    do_cron "$ID_CRU" "a" "$cron_File" "month=* week=* day=* hour=* min=$cron_Time" "min"  "$scripts_sh" "update" 
			fi
		fi
	elif iseq "$1" "d";then	
        do_cron "$ID_CRU" "d" "$cron_File"			
	fi
}
#======================================================================================
set_scripts(){
    #remove old scripts
	if iseq "$OS_TYPE" "merlin";then
        if iseq "$1" "a";then
		    del_tmpfile "/jffs/scripts" "wan-start" 2>/dev/null
			del_tmpfile "/jffs/scripts" "ddns-start" 2>/dev/null
			del_tmpfile "/jffs/scripts" "post-mount" 2>/dev/null
		    do_create_scripts "a" "/jffs/scripts/wan-start"  "$scripts_sh"	
		    do_create_scripts "a" "/jffs/scripts/ddns-start" "$scripts_sh"
		    do_create_scripts "a" "/jffs/scripts/post-mount" "$scripts_sh"	
	    elif iseq "$1" "d";then	
		    do_create_scripts "d" "/jffs/scripts/wan-start"  "$scripts_sh"	
	        do_create_scripts "d" "/jffs/scripts/ddns-start" "$scripts_sh"
            do_create_scripts "d" "/jffs/scripts/post-mount" "$scripts_sh"		
	    fi
	elif iseq "$OS_TYPE" "padavan";then
	    if iseq "$1" "a";then
		    del_tmpfile "/etc/storage" "post_wan_script.sh" 2>/dev/null
		    do_create_scripts "a" "/etc/storage/post_wan_script.sh" "$scripts_sh"	
		elif iseq "$1" "d";then	
		    do_create_scripts "d" "/etc/storage/post_wan_script.sh" "$scripts_sh"	
		fi	
	elif iseq "$OS_TYPE" "openwrt" || iseq "$OS_TYPE" "pandorabox";then
	    if iseq "$1" "a";then
		    del_tmpfile "/etc/hotplug.d/iface" "99-sharealiddns" 2>/dev/null
			del_tmpfile "/etc/init.d" "sharealiddns" 2>/dev/null
		    do_create_scripts "a" "/etc/hotplug.d/iface/99-sharealiddns" "$scripts_sh"	
			do_create_scripts "a" "/etc/init.d/sharealiddns" "$scripts_sh"	
		elif iseq "$1" "d";then	
		    do_create_scripts "d" "/etc/hotplug.d/iface/99-sharealiddns" "$scripts_sh"	
			do_create_scripts "d" "/etc/init.d/sharealiddns" "$scripts_sh"	
		fi	
	fi
}
#======================================================================================
do_end(){
	if iseq "$isRUN" 1 || ! do_run_check;then
        do_cron "$ID_CRU" "a" "$cron_File" "month=* week=* day=* hour=* min=2" "min" "$scripts_sh" "update" 
		rm -f "$FL"
		exit 1
	fi
}
#======================================================================================
do_realupdate(){
    set_cron "$1" "$2" "$3"
	set_scripts "$1" "$2" "$3"
	do_end
	rm -rf "$FL"
}
#======================================================================================
do_aliddns_log(){
    local v1="$1";local v2="$2";local log="";local t=`date '+%Y-%m-%d-%H:%M:%S'`
    local m="$Count:[$aliddns_type]-[$aliddns_name.$aliddns_domain]"
	iseq "$islog" 0 && return 0
	case "$v1" in
	    "added")
	        if iseq "$aliddns_type" "A";then
			    log="[$t]-$m-$xan_ipvx_IP[$wan_ipvx_IP]-[$v1-$v2]"
			elif iseq "$aliddns_type" "AAAA";then
	            if isEmpty "$aliddns_lan_mac";then
				    log="[$t]-$m-$xan_ipvx_IP[$wan_ipvx_IP]-[$v1-$v2]"
				else
	                log="[$t]-$m-$xan_ipvx_IP[$wan_ipvx_IP]-[$aliddns_lan_mac]-[$v1-$v2]"
				fi
			fi
	        ;;
		"update")
		    if iseq "$aliddns_type" "A";then
			    log="[$t]-$m-$xan_ipvx_IP[$wan_ipvx_IP]-[$v1-$v2]"
			elif iseq "$aliddns_type" "AAAA";then
	            if isEmpty "$aliddns_lan_mac";then
				    log="[$t]-$m-$xan_ipvx_IP[$wan_ipvx_IP]-[$v1-$v2]"
				else
	                log="[$t]-$m-$xan_ipvx_IP[$wan_ipvx_IP]-[$aliddns_lan_mac]-[$v1-$v2]"
				fi
			fi
	        ;;
		"remove")
		    if iseq "$aliddns_type" "A";then
			    log="[$t]-$m-Record_Ids[$Record_Ids]-[$v1-$v2]"
			elif iseq "$aliddns_type" "AAAA";then
	            if isEmpty "$aliddns_lan_mac";then
 				    log="[$t]-$m-Record_Ids[$Record_Ids]-[$v1-$v2]"
				else
	                log="[$t]-$m-Record_Ids[$Record_Ids]-[$aliddns_lan_mac]-[$v1-$v2]"
				fi
	        fi
			;;
		"getwanip")
		    if iseq "$aliddns_type" "A";then
			    log="[$t]-$m-$xan_ipvx_IP[$wan_ipvx_IP]-[$v1-$v2]"
			elif iseq "$aliddns_type" "AAAA";then
	            if isEmpty "$aliddns_lan_mac";then
				    log="[$t]-$m-$xan_ipvx_IP[$wan_ipvx_IP]-[$v1-$v2]"
				else
				    v1='getlanip'
	                log="[$t]-$m-$xan_ipvx_IP[$wan_ipvx_IP]-[$aliddns_lan_mac]-[$v1-$v2]"
				fi
	        fi
			;;
		"dnsExist")
		    if iseq "$aliddns_type" "A";then
			    log="[$t]-$m-$xan_ipvx_IP[$wan_ipvx_IP]-[$v1-$v2]"
            elif iseq "$aliddns_type" "AAAA";then				
	            if isEmpty "$aliddns_lan_mac";then
       				log="[$t]-$m-$xan_ipvx_IP[$wan_ipvx_IP]-[$v1-$v2]"
				else
	                log="[$t]-$m-$xan_ipvx_IP[$wan_ipvx_IP]-[$aliddns_lan_mac]-[$v1-$v2]"
				fi
	        fi
			;;
		"status")
		    if iseq "$aliddns_type" "A";then
			    log="[$t]-$m-[$v1 $v2]"	
			elif iseq "$aliddns_type" "AAAA";then
	            if isEmpty "$aliddns_lan_mac";then
				    log="[$t]-$m-[$v1-$v2]"
				else
	                log="[$t]-$m-[$v1-$v2]"
				fi
			fi
	        ;;
		"getrecord")
		    log="[$t]-$m-Record_Ids[$Record_Ids]-[$v1-$v2]"	
		    ;;
		"checkwanip")
		    log="[$t]-$m-$xan_ipvx_IP[$wan_ipvx_IP]-[$v1-$v2]"
	        ;;
	   *)
    esac
	if [ ! -f "$aliddns_log" ];then
	    echo "$log" > "$aliddns_log" 
	else
	    echo "$log" >> "$aliddns_log" 
	fi
	
	if [ ! -f "$aliddns_msg" ];then
	    echo "$log" > "$aliddns_msg" 
	else
	    echo "$log" >> "$aliddns_msg" 
	fi
	return 0
}
#======================================================================================
do_showlog(){
    local msg="";local m="";local n=0;local i=1
	if [ -f "$aliddns_log" ];then
	    RMSPACEROWFILE "$aliddns_log"
	    msg=$(cat "$aliddns_log")
		if [ -n "$msg" ];then
		    n=$(echo "$msg" | awk 'END{print NR}')
		    until [ "$i" -gt "$n" ];do 
			    m=$(echo "$msg" | awk "NR==$i{print}")
		        logs "$m" 
				i=$(sadd $i 1) 	
		    done
		    logs "" "$LS"
		fi
	fi
}
#======================================================================================
set_success(){
    if iseq "$1" 1;then
		issuccess="$issuccess $Count"
		logs "$Count:$3..." "" "rb"
	elif iseq "$1" 0;then	
        isfailed="$isfailed $Count"
        logs "$Count:$3..." "" "rb"
	fi
    return 0
}
#======================================================================================
show_success(){
    local again_num=0;local m="";local msg="";local n=0;local i=1
	if iseq "$isRUN" 1 || ! do_run_check;then
        do_cron "$ID_CRU" "a" "$cron_File" "month=* week=* day=* hour=* min=2" "min" "$scripts_sh" "update" 
		rm -f "$FL"
		exit 1
	fi
	logs "" "$LS"
	if isne "$currtimer" 0;then
	    lasttimer=$(($(date +%s) - $currtimer))
	    logs "time consuming:${lasttimer}s" "" "rb" "t"
	fi
	if isNotEmpty "$issuccess";then
	    for c in $issuccess;do
	        get_aliddns_conf "$c"
		    m="$c:[$aliddns_type]-[$aliddns_name.$aliddns_domain]$1 for success operation"
		    logs "$m" "" "ys" "t"
	    done
	fi
	if isNotEmpty "$isfailed";then
	    if [ -f "$isfailed_again_num" ];then
		    again_num=$(cat "$isfailed_again_num" | grep -w "again_num" | RMSTRING "again_num=" | TRIM)
			if check_number "$again_num";then
				again_num=$(sadd $again_num 1)	
			else
			    again_num=1
			fi
			echo "again_num=$again_num" > "$isfailed_again_num"
		else
		    echo "again_num=1" > "$isfailed_again_num"
		fi
	    echo "lCount=$isfailed" > "$isfailed_again"
	    for c in $isfailed;do
	        get_aliddns_conf "$c"
		    m="$c:[$aliddns_type]-[$aliddns_name.$aliddns_domain]$1 for failed operation"
		    logs "$m" "" "vs" "w"
	    done
	else
	    rm -rf "$isfailed_again_num" 
	    rm -rf "$isfailed_again"     
	fi
	logs "" "$LS"
	if [ -f "$aliddns_msg" ];then
	    RMSPACEROWFILE "$aliddns_msg"
	    msg=$(cat "$aliddns_msg")
		if [ -n "$msg" ];then
		    n=$(echo "$msg" | awk 'END{print NR}')
		    until [ "$i" -gt "$n" ];do 
			    m=$(echo "$msg" | awk "NR==$i{print}")
		        logs "$m" 
				i=$(sadd $i 1) 	
		    done
		    logs "" "$LS"
		fi
	fi
	do_removerow "$aliddns_log" 300   
	return 0
}
#======================================================================================
eui64() {
    local m0=$1
    local m1=`echo $m0 |cut -f1 -d:`
    local m2=`echo $m0 |cut -f2 -d:`
    local m3=`echo $m0 |cut -f3 -d:`
    local m4=`echo $m0 |cut -f4 -d:`
    local m5=`echo $m0 |cut -f5 -d:`
    local m6=`echo $m0 |cut -f6 -d:`
    local m1_xor=$((0x$m1 ^ 2))
    printf "%02x%02x:%02xff:fe%02x:%02x%02x" ${m1_xor} 0x${m2} 0x${m3} 0x${m4} 0x${m5} 0x${m6}
}
#======================================================================================
do_geneui64(){
	local m="$1";local e="$2"
    if iseq "$iseui64" 1;then
        ipv6_eui64=$(eui64 $m)
	    local v0=$(echo $wan_ipv6_IP | cut -d ':' -f 1)
	    local v1=$($IP2 -6 addr show dev $e | grep -w $v0 | grep -w "inet6" | grep -v "^fe80" | awk "NR==1{print}" | sed -n '/inet/{s!.*inet6* !!;s!s.*!!p}')
	    local v2=$(echo $v1 | cut -d ':' -f 1,2,3,4)
	    local v3=$(echo $v1 | cut -d '/' -f 2)
	    local v4="$v2::"
	    local v5="$v2::1"
	    if isNotEmpty "$ipv6_eui64" isNotEmpty "$v2" && isNotEmpty "$v3" && isNotEmpty "$v4" isNotEmpty "$v5";then
	        nvram set ipv6_prefix_length="$v3"
	        nvram set ipv6_prefix="$v4"
		    nvram set ipv6_rtr_addr="$v5"
		    lan_ipv6_IP_custom="$v2:$ipv6_eui64"
	    fi
	fi
}
#======================================================================================
do_remove_client(){
   local v;local p;local m
   while :;do
        v=`ip -6 neigh show dev $ETH | grep -v '^fe80'`	
	    p=$(echo $v | cut -d ' ' -f 1)
	    m=$(echo $v | cut -d ' ' -f 3)
	    isEmpty "$p" && isEmpty "$m" && break
	    logs "remove permanent for client[$v]" "" "gb"
	    ip -6 neigh del "$p" lladdr "$m" dev $ETH
    done
	return 0
}
#======================================================================================
do_client(){
    local jj="";local pl;local ml;local sl;local nn;local ii=1;local p;local m;local s;local t
    if iseq "$2" "ipv4";then
        jj=-4    
    elif iseq "$2" "ipv6";then
	    jj=-6
    else
        logs "Usage of ipv4:[sh $scripts_sh $1 ipv4]" "" "rb" "w"
		logs "Usage of ipv6:[sh $scripts_sh $1 ipv6]" "" "rb" "w"
		rm -f "$FL"
		exit 1
   fi
   while :;do
        ii=1
		t=`date '+%Y-%m-%d-%H:%M:%S'`
        pl=$(ip $jj neigh show dev $ETH | grep -v '^fe80' | grep -v '::1' | awk '{print $1}')
		ml=$(ip $jj neigh show dev $ETH | grep -v '^fe80' | grep -v '::1' | awk '{print $3}')
		sl=$(ip $jj neigh show dev $ETH | grep -v '^fe80' | grep -v '::1' | awk '{print $4}')
		nn=$(echo "$pl" | awk 'END{print NR}')
		[ -z "$pl" ] && logs "No client was found[没有发现客户端]" "" "yb" && rm -f "$FL" && exit 1
		until [ "$ii" -gt "$nn" ];do 
		    p=$(echo "$pl" | awk "NR==$ii{print}")
			m=$(echo "$ml" | awk "NR==$ii{print}")
			s=$(echo "$sl" | awk "NR==$ii{print}" | set_lowercase)	
			if [ -n "$p" -a -n "$m" -a "$s" ];then
                if [ "$s" == "delay" ];then		
	                logs "[$t]-[$p]-[$m]-[$s]-[延时邻居]" "" "y"
		        elif [ "$s" == "stale" ];then				
		            logs "[$t]-[$p]-[$m]-[$s]-[过时邻居]" "" "y"
		        elif [ "$s" == "reachable" ];then		
		            logs "[$t]-[$p]-[$m]-[$s]-[可达邻居]" "" "y"
		        elif [ "$s" == "used" ];then			
		            logs "[$t]-[$p]-[$m]-[$s]-[使用邻居]" "" "y"  
                elif [ "$s" == "probe" ];then			
		            logs "[$t]-[$p]-[$m]-[$s]-[探查邻居]" "" "y"     					
				elif [ "$s" == "failed" ];then			
		            logs "[$t]-[$p]-[$m]-[$s]-[废弃邻居]" "" "y"  
                elif [ "$s" == "empty" ];then			
		            logs "[$t]-[$p]-[$m]-[$s]-[空闲邻居]" "" "y" 
                elif [ "$s" == "incomplete" ];then			
		            logs "[$t]-[$p]-[$m]-[$s]-[未完成邻居]" "" "y" 
                elif [ "$s" == "ref" ];then			
		            logs "[$t]-[$p]-[$m]-[$s]-[刷新邻居]" "" "y"    		   					
                else
			        logs "[$t]-[$p]-[$m]-[$s]-[消失邻居]" "" "g" "t"
				fi
				
			else
			    logs "[$t]-[$p]-[$m]-[$s]-[消失邻居]" "" "g" "t"
			fi
			ii=$(sadd $ii 1) 
		done
		sleep 5
	done
}
#======================================================================================
do_create_scripts(){
    local mymode="$1";local myscripts="$2";local myshell="$3";local myshellproc=""
    if iseq "$mymode" "a";then
	    if [ ! -f "$myscripts" ];then
	        if iseq "$OS_TYPE" "openwrt" || iseq "$OS_TYPE" "pandorabox";then	
		        echo "#!/bin/sh /etc/rc.common" > "$myscripts"
		    else
		        echo "#!/bin/sh" > "$myscripts"
			fi
		fi
		if isEmpty "$(cat $myscripts | grep -o 'myshell')";then
		    echo '' >> "$myscripts"
		    if iseq "$myscripts" "/jffs/scripts/wan-start";then 
			    echo "myshell=$myshell" >> "$myscripts"	
				echo "myshellname=$(echo $myshell| awk -F '/' '{print $NF}')" >> "$myscripts"		
				echo "myready=1" >> "$myscripts"
                echo "mynum=0" >> "$myscripts"
				echo 'echo "pid=$$" > "/tmp/wan_start.pid"' >> "$myscripts"
                echo 'while [ "$mynum" -lt 120 ];do' >> "$myscripts"
                echo '    [ -x "$myshell" ] && myready=0 && break' >> "$myscripts"
				echo "    mynum=\$((\$mynum+1))" >> "$myscripts"
				echo "    sleep 1" >> "$myscripts"
				echo "done" >> "$myscripts" 
				echo "myshellproc=\$(ps | grep -v grep | grep -o \$myshellname)" >> "$myscripts" 
				echo 'if [ "$myready" -eq 0 -a -z "$myshellproc" ];then' >> "$myscripts" 
				echo "    [ \$(nvram get ipv6_service | tr 'A-Z' 'a-z') != 'disabled' ] && service restart_dhcp6c" >> "$myscripts"
				echo '    "$myshell" update' >> "$myscripts" 
				echo "fi" >> "$myscripts" 
			elif iseq "$myscripts" "/jffs/scripts/ddns-start" || iseq "$myscripts" "/jffs/scripts/post-mount";then
				echo "myshell=$myshell" >> "$myscripts"
				echo "myshellname=$(echo $myshell| awk -F '/' '{print $NF}')" >> "$myscripts"	
			    echo "myshellproc=\$(ps | grep -v grep | grep -o \$myshellname)" >> "$myscripts" 
				echo '[ -z "$myshellproc" -a -x "$myshell" ] && "$myshell" update' >> "$myscripts"
			elif iseq "$myscripts" "/etc/storage/post_wan_script.sh";then	
			    echo "myshell=$myshell" >> "$myscripts" 
			    echo "myshellname=$(echo $myshell| awk -F '/' '{print $NF}')" >> "$myscripts"	
				echo "myready=1" >> "$myscripts"
                echo "mynum=0" >> "$myscripts"
				echo "myup=\$1" >> "$myscripts"
				echo 'echo "pid=$$" > "/tmp/wan_start.pid"' >> "$myscripts"
                echo 'while [ "$mynum" -lt 120 ];do' >> "$myscripts"
                echo '    [ -x "$myshell" ] && myready=0 && break' >> "$myscripts"
				echo "    mynum=\$((\$mynum+1))" >> "$myscripts"
				echo "    sleep 1" >> "$myscripts"
				echo "done" >> "$myscripts" 
				echo "myshellproc=\$(ps | grep -v grep | grep -o \$myshellname)" >> "$myscripts" 
                echo 'if [ "$myup" == "up" -a "$myready" -eq 0 -a -z "$myshellproc" ];then' >> "$myscripts" 
				echo '    "$myshell" update' >> "$myscripts" 
				echo "fi" >> "$myscripts" 	
			elif iseq "$myscripts" "/etc/hotplug.d/iface/99-sharealiddns";then
                echo 'logger "ACTION==========$ACTION==========INTERFACE==========$INTERFACE"' >> "$myscripts"					
			    echo "myshell=$myshell" >> "$myscripts"	
				echo "myshellname=$(echo $myshell| awk -F '/' '{print $NF}')" >> "$myscripts"		
				echo "myready=1" >> "$myscripts"
                echo "mynum=0" >> "$myscripts"
				echo '[ "$ACTION" == "ifup" -a "$INTERFACE" == "wan" ] || exit 0' >> "$myscripts"
				echo 'echo "pid=$$" > "/tmp/wan_start.pid"' >> "$myscripts"
                echo 'while [ "$mynum" -lt 120 ];do' >> "$myscripts"
                echo '    [ -x "$myshell" ] && myready=0 && break' >> "$myscripts"
				echo "    mynum=\$((\$mynum+1))" >> "$myscripts"
				echo "    sleep 1" >> "$myscripts"
				echo "done" >> "$myscripts" 
				echo "myshellproc=\$(ps | grep -v grep | grep -o \$myshellname)" >> "$myscripts" 
				echo 'if [ "$myready" -eq 0 -a -z "$myshellproc" ];then' >> "$myscripts" 
				echo '    "$myshell" update' >> "$myscripts" 
				echo "fi" >> "$myscripts" 
			elif iseq "$myscripts" "/etc/init.d/sharealiddns";then
			    echo "START=99" >> "$myscripts"
				echo "STOP=50" >> "$myscripts"
				echo "myshell=$myshell" >> "$myscripts"	
				echo 'logger "$myshell==========runing"' >> "$myscripts"	
				echo 'restart() { "$myshell" restart; }' >> "$myscripts"
				echo 'start() { "$myshell" start; }' >> "$myscripts"
				echo 'stop() { "$myshell" stop; }' >> "$myscripts"
			fi
		else
		    RMSPACEKEYFILE "$myscripts"	"myshell"		
			myshell=$(exurl $myshell)
	        sed -i "s/^myshell=.*/myshell=${myshell}/g" "$myscripts"	
		fi   
        RMSPACEKEYFILE "$myscripts"	"myshell"		
	    RMSPACEROWFILE "$myscripts"
	    chmod +x "$myscripts"
    elif iseq "$mymode" "d";then
	    RMSPACEKEYFILE "$myscripts"	"myshell"		
	    RMSPACEROWFILE "$myscripts"
		
        if [ -f "$myscripts" ];then
		    if iseq "$myscripts" "/etc/storage/post_wan_script.sh";then	 
	            RMCURROWTOLISTFILE "$myscripts" "myshell" 14
			elif iseq "$myscripts" "/jffs/scripts/wan-start";then 
			    RMCURROWTOLISTFILE "$myscripts" "myshell" 14
			elif iseq "$myscripts" "/etc/hotplug.d/iface/99-sharealiddns";then 
				for f in `ls /etc/hotplug.d/iface/99-sharealiddns* 2>&1 | grep -E '99-sharealiddns'`;do
                    if [ -f "$f" ];then
                        rm -f "$f"
                    fi
                done
			elif iseq "$myscripts" "/etc/init.d/sharealiddns";then			
				for f in `ls /etc/init.d/sharealiddns* 2>&1 | grep -E 'sharealiddns'`;do
                    if [ -f "$f" ];then
                        rm -f "$f"
                    fi
                done
			else
			    RMROWFILE "$myscripts" "myshell"
				RMROWFILE "$myscripts" "myshellname"
				RMROWFILE "$myscripts" "myshellproc"
				#del old
				RMROWFILE "$myscripts" "myservice"
				RMROWFILE "$myscripts" "wan_start"
				RMROWFILE "$myscripts" "restart_dhcp6c"
                RMSPACEROWFILE "$myscripts"
            fi 			
	    fi
    fi
}
#======================================================================================
get_wan_startPID(){
    local pid="0"
	if iseq "$OS_TYPE" "merlin" || iseq "$OS_TYPE" "padavan" || iseq "$OS_TYPE" "openwrt" || iseq "$OS_TYPE" "pandorabox";then 
        if [ -f "$iswan_start" ];then
	        pid=$(cat "$iswan_start" | grep -w "pid" | RMSTRING "pid=" | TRIM)
	        if isNotEmpty "$pid" && check_number "$pid";then
		        echo "$pid"
		    else
			    echo "0"
		    fi
	    else
	        echo "999"
	    fi
	else
	    echo "999"
	fi
}
#======================================================================================
get_dhcp6cPID(){
    local PID=""
	PID=$(ps | grep -v grep | tr 'A-Z' 'a-z' | grep -wE 'odhcp6c|dhcp6c' | awk -F ' ' '{print $1}' | tail -n1)
	if isNotEmpty "$PID" && check_number "$PID";then
	    echo "$PID"
	else
	    echo "0"
	fi	
}
#======================================================================================
do_pppoe(){
    if iseq "$OS_TYPE" "merlin";then	
        if iseq "$1" "ipv46";then	
		    logs "=========================restart_wan=========================" "" "rl" "w"
		    service restart_wan >/dev/null 2>&1
			if isne "$(nvram get ipv6_service | tr 'A-Z' 'a-z')" "disabled" && iseq "$isipv6_domain" 1 && iseq "$isIPV6" 0;then
			    logs "Force restart dhcp6c to get the correct IPV6 IP[强制重启dhcp6c以获取正确的IPV6 IP]" "" "rl" "w"
			    logs "FIX=========================restart_dhcp6c=========================FIX" "" "rl" "w"
		        service restart_dhcp6c >/dev/null 2>&1
		    fi
		elif iseq "$1" "ipv4";then	
		    logs "=========================restart_wan=========================" "" "rl" "w"
		    service restart_wan >/dev/null 2>&1
		elif iseq "$1" "ipv6";then
            if isne "$(nvram get ipv6_service | tr 'A-Z' 'a-z')" "disabled" && iseq "$isipv6_domain" 1 && iseq "$isIPV6" 0;then
			    logs "Force restart dhcp6c to get the correct IPV6 IP[强制重启dhcp6c以获取正确的IPV6 IP]" "" "rl" "w"
			    logs "FIX=========================restart_dhcp6c=========================FIX" "" "rl" "w"
		        service restart_dhcp6c >/dev/null 2>&1
		    fi		
		fi
	elif iseq "$OS_TYPE" "padavan";then
	    logs "=========================restart_wan=========================" "" "rl" "w"
		restart_wan >/dev/null 2>&1
	elif iseq "$OS_TYPE" "openwrt" || iseq "$OS_TYPE" "pandorabox";then
	    logs "=========================ifup wan=========================" "" "rl" "w"
		ifup wan >/dev/null 2>&1
	fi
}
#======================================================================================
get_externalIP(){
    local r=1;local i=1;local j=3;local wp="";local pl=""
	externalIP4="";externalIP6="";wanstartPID=0;dhcp6cPID=0
	#get external IP4
	if iseq "$isipv4_domain" 1;then
	    logs "Detecting external IPV4 IP[正在探测外网IPV4 IP]" "" "yb" "t"
	    wp="";r=1;i=1;j=$(echo "$u4" | ROWTOCOLUMN | RMSURPLUSSPACE | awk 'END{print NR}')	
	    for u in $u4;do
	        wp=$(get_url_cmd $u 3) >/dev/null 2>&1		
	        wanstartPID=$(get_wan_startPID)	
		    if isNotEmpty "$wp" && public_ipv4_check "$wp" && isgt "$wanstartPID" 0;then
		        logs "RIGHT=>$i/$j:externalIP4[${wp}]-wanstartPID[${wanstartPID}]-[$u]" "" "yl" "t"
		        externalIP4="$wp" && r=0 && break
            else
			    logs "ERROR=>$i/$j:externalIP4[${wp}]-wanstartPID[${wanstartPID}]-[$u]" "" "yl" "t"	
			    if isgt "$i" 10;then
			        do_pppoe "ipv46"
			        go_sleep 15   
			        logs "Continue to detection the network..." "" "yb" "t"			
                fi
            fi				
		    isge "$i" "$j" && break 
		    i=$(sadd $i 1)
        done 
        if isEmpty "$wp";then
	        r=1;i=1;j=3
	        while :;do
	            if iseq "$wan_ifname" "";then
	                pl=$($IP2 addr show                 | sed -n '/inet/{s!.*inet* !!;s!/.*!!p}' | sed 's/peer.*//' | grep -v 'inet6')
	            else
	                pl=$($IP2 addr show dev $wan_ifname | sed -n '/inet/{s!.*inet* !!;s!/.*!!p}' | sed 's/peer.*//' | grep -v 'inet6') 
	            fi
	            for p in $pl;do
	                p=$(echo $p | TRIMALL)	
		            isNotEmpty "$p" && public_ipv4_check "$p" && wp="$p" && break   
	            done
		        wanstartPID=$(get_wan_startPID)	 
		        if isNotEmpty "$wp" && isgt "$wanstartPID" 0;then
		            logs "RIGHT=>$i/$j:externalIP4[${wp}]-wanstartPID[${wanstartPID}]" "" "yl" "t"
		            externalIP4="$wp" && r=0 && break
                else
		            logs "ERROR=>$i/$j:externalIP4[${wp}]-wanstartPID[${wanstartPID}]" "" "yl" "t"	
			        do_pppoe "ipv46"
			        go_sleep 15   
			        logs "Continue to detection the network..." "" "yb" "t"		
                fi	
		        isge "$i" "$j" && break 
		        i=$(sadd $i 1)
            done
	    fi
	    if isne "$r" 0;then
            logs "External IPv4 IP undetectable[检测不到外网IPV4 IP]" "" "ra" "w"
	        do_cron "$ID_CRU" "a" "$cron_File" "month=* week=* day=* hour=* min=1" "min" "$scripts_sh" 
		    return 1
	    fi
	else
	    wanstartPID=$(get_wan_startPID)	
	fi
	
	if iseq "$isipv6_domain" 0 || iseq "$isIPV6" 1;then
	    dhcp6cPID=$(get_dhcp6cPID)	
		return 0
	fi
	
	#get external IP6
	logs "Detecting external IPV6 IP[正在探测外网IPV6 IP]" "" "yb" "t"	
	wp="";r=1;i=1;j=$(echo "$u6" | ROWTOCOLUMN | RMSURPLUSSPACE | awk 'END{print NR}')
    for u in $u6;do
	        wp=$(get_url_cmd $u 3) >/dev/null 2>&1
            dhcp6cPID=$(get_dhcp6cPID)	
		if isNotEmpty "$wp" && public_ipv6_check "$wp" && isgt "$dhcp6cPID" 0;then
		    logs "RIGHT=>$i/$j:externalIP6[${wp}]-dhcp6cPID[${dhcp6cPID}]-[$u]" "" "yl" "t"
            externalIP6="$wp" && r=0 && break
		else
		    logs "ERROR=>$i/$j:externalIP6[${wp}]-dhcp6cPID[${dhcp6cPID}]-[$u]" "" "yl" "t"	
	        if isgt "$i" 10;then
		        do_pppoe "ipv6"
		        go_sleep 15
		        logs "Continue to detection the network..." "" "yb" "t"
            fi				
	    fi
	    isge "$i" "$j" && break 
	    i=$(sadd $i 1)
    done
	if isEmpty "$wp";then
	    r=1;i=1;j=3
	    while :;do
	        if iseq "$wan_ifname" "";then
	            pl=$($IP2 addr show                 | sed -n '/inet/{s!.*inet6* !!;s!/.*!!p}' | sed 's/peer.*//' | grep -v '^fe80' | grep -v 'inet')
	        else
	            pl=$($IP2 addr show dev $wan_ifname | sed -n '/inet/{s!.*inet6* !!;s!/.*!!p}' | sed 's/peer.*//' | grep -v '^fe80' | grep -v 'inet') 
	        fi		
	        for p in $pl;do
	            p=$(echo $p | TRIMALL)	
		        isNotEmpty "$p" && public_ipv6_check "$p" && wp="$p" && break   
	        done
			dhcp6cPID=$(get_dhcp6cPID)	
		    if isNotEmpty "$wp" && isgt "$dhcp6cPID" 0;then
			    logs "RIGHT=>$i/$j:externalIP6[${wp}]-dhcp6cPID[${dhcp6cPID}]" "" "yl" "t"
				externalIP6="$wp" && r=0 && break
		    else
	            logs "ERROR=>$i/$j:externalIP6[${wp}]-dhcp6cPID[${dhcp6cPID}]" "" "yl" "t"	
			    do_pppoe "ipv6"
			    go_sleep 15
			    logs "Continue to detection the network..." "" "yb" "t"	
		    fi
		    isge "$i" "$j" && break 
		    i=$(sadd $i 1)
        done
	fi
	iseq "$r" 0 && return 0
	logs "External not have IPV6 IP..." "" "ra" "w"
	logs "外网确实没有IPV6 IP，请检查：" "" "ra" "w"
	logs "    1、路由器或光猫设置是否正确。" "" "ra" "w"
	logs "    2、通信运营商是否推送IPV6 IP。" "" "ra" "w"
	logs "    3、其他未知原因导致无法探测到IPV6 IP。" "" "ra" "w"
	rm -f "$FL"
	exit 1
}
#======================================================================================
do_run_check(){
	iseq "$wanstartPID" "$(get_wan_startPID)" && return 0
	logs "FIX======[External IP has changed, scripts automatically enter the background mode, please do not intervene.]======FIX" "" "rl" "w"
	logs "FIX======[外网IP已经发生改变，脚本自动进入后台运行模式，请不要做任何干预。]======FIX" "" "rl" "w"
	isRUN=1
	return 1
}
#======================================================================================
do_wan_state_check(){
    
    local n="$1";local rs="";local rp="";local ep=2
    if [ "$n" == "0" ];then
        rs="$(nvram get wan0_realip_state)"
        if [ "$rs" == "2" ];then
            rp="$(nvram get wan0_realip_ip)"
			if [ "$rp" == "$(nvram get wan0_ipaddr)" ];then
			    ep=1
			else
			    ep=0
			fi
        else
            ep=2
        fi
    elif [ "$n" == "1" ];then
        rs="$(nvram get wan1_realip_state)"
        if [ "$rs" == "2" ];then
            rp="$(nvram get wan1_realip_ip)"
			if [ "$rp" == "$(nvram get wan1_ipaddr)" ];then
                ep=1
			else
			    ep=0
			fi
        else
            ep=2
        fi
    fi
	echo "$rp"
}
#======================================================================================
do_init(){
    if [ "$2" != "setconf" -a "$2" != "start" -a "$2" != "stop" -a "$2" != "restart" -a "$2" != "check" -a "$2" != "update" -a "$2" != "again" -a "$2" != "add" -a "$2" != "removeall" -a "$2" != "remove" -a "$2" != "status" -a "$2" != "monitor" -a "$2" != "checkwanip" -a "$2" != "showlog" -a "$2" != "kill" -a "$2" != "client" ];then
        logs "Usage: $1 setconf|start|stop|restart|check|update|again|add|removeall|remove|status|monitor|checkwanip|showlog|kill|client" "" "yb" "w" >&2
       rm -f "$FL"
	   exit 1
    fi
	local i=1;local j=30;local r=""
	
	if iseq "$OS_TYPE" "merlin";then
	    nvram set jffs2_enable=1
	    nvram set jffs2_scripts=1
	    nvram commit
	    [ -d "/jffs/scripts" ] && chmod +x /jffs/scripts/*
		until [ "$i" -gt "$j" ];do
            [ "$(nvram get success_start_service)" == "1" ] && break			
	        sleep 1
		    i=$(sadd $i 1)	
        done
		ETH="br0"
		iseq "$(nvram get ipv6_service | tr 'A-Z' 'a-z')" "disabled" && isIPV6=1
	elif iseq "$OS_TYPE" "padavan";then
	    if [ "$(nvram get wan_ppp_alcp)" != "1" -o "$(nvram get wan_ppp_echo_en)" != "1" ];then
	        nvram set wan_ppp_alcp=1
            nvram set wan_ppp_echo_en=1
            nvram set wan_ppp_echo_failure=6
            nvram set wan_ppp_echo_interval=30
		    nvram commit
			restart_wan >/dev/null 2>&1
		fi
	    cron_File=$(ls /etc/storage/cron/crontabs) 
	    if [ -n "/etc/storage/cron/crontabs/$cron_File" ];then
	        cron_File="/etc/storage/cron/crontabs/$cron_File"
	    fi
	    ETH="br0"
		isEmpty "$(nvram get ip6_service | tr 'A-Z' 'a-z')" && isIPV6=1
	elif iseq "$OS_TYPE" "openwrt" || iseq "$OS_TYPE" "pandorabox";then 
	    r="1"
	    for w in wan wan6;do
		    {
		        local p=$(uci get network.${w}.proto) 
			    local u=$(uci get network.${w}.username)
			    local k=$(uci get network.${w}.keepalive)
			} 2>/dev/null
            if [ "$p" == "pppoe" -a -n "$u" ];then	
                if isEmpty "$k";then
                    uci set network.${w}.keepalive='3 5'
                    r="0" 
                fi
		    fi
		done
		if iseq "$r" 0;then
		    uci commit  				
            /etc/init.d/network restart 
	    fi
	    cron_File=$(ls /etc/crontabs) 
	    if [ -n "/etc/crontabs/$cron_File" ];then
	        cron_File="/etc/crontabs/$cron_File"
		else
		    cron_File="/etc/crontabs/root"
			echo "" > "$cron_File"
	    fi
	    ETH="br-lan"
		iseq "$(cat /etc/config/network | set_lowercase | grep -w 'ipv6' | awk '{print $3}' | RMSTRING "'" | RMSTRING '"')" 0 && isIPV6=1	
	fi
	
	if isexists "sort";then
	    SORT="$existspath"
		logs "$SORT exists=0" "" "y" 
    else
	    logs "You have to install sort[你必须安装sort]" "" "rb" "e" 
		rm -f "$FL"
		exit 1
	fi
	
	if isexists "nslookup";then
	    NSLOOKUP="$existspath"
		logs "$NSLOOKUP exists=0" "" "y" 
	else
	    logs "You have to install nslookup[你必须安装nslookup]" "" "rb" "e" 
		rm -f "$FL"
		exit 1
	fi
	
	if isexists "/usr/bin/openssl";then
	    OPENSSL="$existspath"
	elif isexists "/usr/sbin/openssl";then
	    OPENSSL="$existspath"
	elif isexists "/bin/openssl";then
	    OPENSSL="$existspath"
	elif isexists "/sbin/openssl";then
		OPENSSL="$existspath"
	elif isexists "openssl";then
		OPENSSL="$existspath"
	else
	    logs "You have to install openssl[你必须安装openssl]" "" "rb" "e" 
		rm -f "$FL"
		exit 1
	fi
	
	if [ -n "$OPENSSL" ];then
	    local str1="A";local str2="a"
	    if [ -n "$(echo $str1 | $OPENSSL dgst -sha1 -hmac $str2 -binary | $OPENSSL base64)" ];then
	        logs "$OPENSSL exists=0" "" "y" 
	    else
			logs "$OPENSSL is unavailable[${OPENSSL}无法使用]" "" "rb" "e" 
			rm -f "$FL"
			exit 1
	    fi
	fi
	
	if isexists "/usr/bin/ip";then
	    IP2="$existspath"
		logs "$IP2 exists=0" "" "y" 
	elif isexists "/usr/sbin/ip";then
	    IP2="$existspath"
		logs "$IP2 exists=0" "" "y" 
	elif isexists "/bin/ip";then
	    IP2="$existspath"
		logs "$IP2 exists=0" "" "y" 
	elif isexists "/sbin/ip";then
	    IP2="$existspath"
		logs "$IP2 exists=0" "" "y" 
	elif isexists "ip";then
	    IP2="$existspath"
		logs "$IP2 exists=0" "" "y" 
	else
		logs "You have to install ip[你必须安装ip]" "" "rb" "e" 
		rm -f "$FL"
		exit 1
	fi
	
    if isexists "/usr/bin/wget";then
	    WGET="$existspath"
		logs "$WGET exists=0" "" "y"
		iswget=0
	elif isexists "/usr/sbin/wget";then
	    WGET="$existspath"
		logs "$WGET exists=0" "" "y"
		iswget=0
	elif isexists "/bin/wget";then
	    WGET="$existspath"
		logs "$WGET exists=0" "" "y"
		iswget=0
	elif isexists "/sbin/wget";then
	    WGET="$existspath"
		logs "$WGET exists=0" "" "y"
		iswget=0
	elif isexists "wget";then
	    WGET="$existspath"
		logs "$WGET exists=0" "" "y"
		iswget=0
	else
		logs "You did not install wget[你没有安装wget]" "" "y" "w" 
	fi
		
    if isexists "/usr/bin/curl";then
	    CURL="$existspath"
		logs "$CURL exists=0" "" "y" 
		iscurl=0
	elif isexists "/usr/sbin/curl";then
	    CURL="$existspath"
		logs "$CURL exists=0" "" "y" 
		iscurl=0
	elif isexists "/bin/curl";then
	    CURL="$existspath"
		logs "$CURL exists=0" "" "y" 
		iscurl=0
	elif isexists "/sbin/curl";then
	    CURL="$existspath"
		logs "$CURL exists=0" "" "y" 
		iscurl=0
	elif isexists "curl";then
	    CURL="$existspath"
		logs "$CURL exists=0" "" "y" 
		iscurl=0
	else
	    logs "You did not install curl[你没有安装curl]" "" "y" "w" 
	fi

	if isEmpty "$WGET" && isEmpty "$CURL";then
	    logs "You have to install wget or curl[你必须安装wget或curl]" "" "rb" "e" 
		rm -f "$FL"
		exit 1
	fi
	
	if iseq "$OS_TYPE" "merlin" || iseq "$OS_TYPE" "padavan";then
	    if isNotEmpty "$(echo $scripts_mount_name | grep -oE 'mnt|media')";then
            r=$(basename $scripts_mount_name)		
            if echo -e "$r" | grep -q '^[a-zA-Z0-9]\+$' && isge $(str_total "$r") 5;then
	            r=""
            else
		        logs "Low-level error: USB partition volume label must be set to English or numeric, and the total number must exceed 4 digits." "" "ra" "e"
	            logs "低级错误：USB分区卷标必须设置为英文或数字，而且总数必须超过4位！" "" "ra" "e"	
				rm -f "$FL"
                exit 1		
            fi
        fi
	fi
    
	if [ "$2" == "setconf" ];then
	    set_aliddns_conf
		rm -f "$FL"
        exit 1
    fi
	
	if iseq "$2" "showlog";then
	    do_showlog 
		rm -f "$FL"
		exit 1
	fi
	
    if [ ! -f "$aliddns_conf" ];then
        logs "No configuration file [account.conf] can be found, exit." "" "rb" "e"
		rm -f "$FL"
	    exit 1
    fi
	
	mkdir -p "$aliddns_root/conf" 
    mkdir -p "$aliddns_root/log"  
	del_tmpfile "$aliddns_root/conf" "aliddns.conf" 2>/dev/null
	
	if iseq "$OS_TYPE" "merlin" || iseq "$OS_TYPE" "padavan";then
        for s in "/tmp/syslog.log" "/tmp/syslog.log-1" "/jffs/syslog.log" "/jffs/syslog.log-1";do
	        [ -f "$s" ] && [ `wc -c "$s" | awk '{print $1}'` -ge 262191 ] && rm -rf "$s"   
	    done    
	fi
	
	if [ -d "/root" ];then
	    rm -rf "/root/$scripts_name"	
	    ln -sf "$scripts_sh" "/root/$scripts_name"	
	    chmod +x "/root/$scripts_name"
	elif [ -d "/home/root" ];then
	    rm -rf "/home/root/$scripts_name"	
	    ln -sf "$scripts_sh" "/home/root/$scripts_name"	
	    chmod +x "/home/root/$scripts_name"
	fi
	
	set_scripts "a"
	
    return 0
}
#======================================================================================
do_begin(){
    if do_init "$1" "$2" "$3" && logs "" "$LS" && get_aliddns_options && set_ipv6_config && get_wan_info && get_externalIP;then   
		goto_ping_wake
		nslookup_dns=$(do_speed_dns "$dns")	 
		case "$2" in
	        check)
		        goto_check "$3"
				show_success "$2"
				do_realupdate "a" "$isfailed" "$2"
				;;
            start|restart|update|add)
			    goto_start "$3"
				show_success "$2"
			    do_realupdate "a" "$isfailed" "$2"
				;;
			stop)
			    do_realupdate "d" "$isfailed" "$2"
				;;
			again)
			    goto_again "$2"
				;;
			status)
                goto_status "$3" "$4"
				show_success "$2"
				do_realupdate "a" "$isfailed" "$2"
				;;	
            monitor)
                while :;do
				    goto_start "$3"
					show_success "$2"
					go_sleep 30
					echo ""
                done
                do_realupdate "a" "$isfailed" "$2"				
                ;;
            remove)
		        goto_remove "$3"
                show_success "$2"
				do_realupdate "a" "$isfailed" "$2"
				iseq "$3" 0 && do_realupdate "d" "$isfailed" "$2"
				;; 		
            removeall)
		        goto_remove 0
				show_success "$2"
				do_realupdate "d" "$isfailed" "$2"
				;;
			checkwanip)
			    goto_checkwanip "$3"
				show_success "$2"	
				do_realupdate "a" "$isfailed" "$2"
				;;
            kill)
				do_realupdate "d" "$isfailed" "$2"
                ;;
            client)
			    do_client "$2" "$3"
                ;;			
            *)
        esac
    fi
}
#======================================================================================
do_begin "$ARGS0" "$ARGS1" "$ARGS2" "$ARGS3" 
rm -f "$FL"
exit 0
#======================================================================================
#======================================================================================
