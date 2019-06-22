#!/usr/bin/bash

music_home=/data/data/io.neoterm/files/home/.music











if [[ ! -e $music_home ]];then
mkdir music_home;fi

busybox=$(which busybox)
if [[ $(which busybox) == "" ]];then echo "busybox not found.";exit 0;fi

clear="${busybox} clear"
grep="${busybox} grep"
head_command="${busybox} head"
egrep="${busybox} egrep"
cat="${busybox} cat"
cut="${busybox} cut"
ps="${busybox} ps"
sed="${busybox} sed"
od="${busybox} od"
seq="${busybox} seq"
ls="${busybox} ls"
tr="${busybox} tr"
rm="${busybox} rm"
awk="${busybox} awk"

if [[ $term_width_set == "" ]];then
    term_width="$($busybox stty size|$cut -d" " -f2)"
else
    term_width="$term_width_set"
fi

#生成指定个数的某个字符
function produce(){
    local product=$(printf "%*s" "$1" " ")
    echo "${product// /"$2"}"
}

#获取字符串长度，中文按照两个长度计算，兼容符号，最好不要搞表情之类的。
function gettextlength_beta(){
    alltext=$(echo "$1"|$sed 's/ /g/g');
    alltext=$(echo "$alltext" |$tr -d "\n" |$od -An -c|$sed 's/[0-9]\{3\} [0-9]\{3\} [0-9]\{3\}/gg/g'|$tr -d " \n")
    alltextlength=${#alltext};
    echo ${alltextlength}
}

#获取字符串长度，更慢
function gettextlength(){
    alltext="$1"
    alltextlength=${#alltext};
    reallength=0;
    index=0;
    while [[ $index < $alltextlength ]];do
        text=$(echo ${alltext:$index:1})
        byte=$(echo $text|$tr -d "\n" |$od -An -x|$tr -d " ")
        length=$((${#byte}/4))
        ((reallength=reallength+length))
        ((index=index+1))
    done
    echo ${reallength}
}

#居中显示
function display_mid(){
    alltextlength=$(gettextlength_beta "$1")
    ((frontlength=(term_width-alltextlength)/2))
    ((behindlength=term_width-alltextlength-frontlength))
    echo "$(produce $frontlength "$2")$1$(produce $behindlength "$2")"
}

#打印一行字符
function display_line(){
    alltextlength=$(gettextlength_beta "$1")
    ((num=term_width/alltextlength))
    echo "$(produce $num "$1")"
}

#居两边显示
function display_side(){
    alltextlength=$(gettextlength_beta "$1$2")
    ((centerlength=term_width-alltextlength))
    echo "$1$(produce $centerlength "$3")$2"
}

#双页显示
function display_double(){
    alltextlength=$(gettextlength_beta "$1")
    ((centerlength=term_width/2-alltextlength))
    echo "$1$(produce $centerlength " ")$2"
}

function request(){
    curl -s -L -k "$1" \
        -H "Referer: https://y.qq.com/portal/profile.html" 
}



function search(){
    local data=$(request "https://c.y.qq.com/soso/fcgi-bin/client_search_cp?ct=24&qqmusic_ver=1298&new_json=1&remoteplace=txt.yqq.center&t=0&aggr=1&cr=1&catZhida=1&lossless=0&flag_qc=0&p=$2&n=10&w=$(echo $1|$tr "_" "+")&&jsonpCallback=searchCallbacksong2020&format=jsonp&inCharset=utf8&outCharset=utf-8&notice=0&platform=yqq&needNewCode=0"|$sed 's/^callback(//g;s/)$//g')
    local resultcount=$(echo "$data"|jq '.data.song.list | length')
    local time=0
    while [[ $time -lt $resultcount ]];do
        local song_name="$(echo "$data"|jq -r ".data.song.list[$time].title")"
        local singer_name="$(echo "$data"|jq -r ".data.song.list[$time].singer[0].name")"
        eval song"$time"_mid=$(echo "$data"|jq -r ".data.song.list[$time].mid")
        eval song"$time"_name=\""$song_name"\"
        eval song"$time"_singer=\""$singer_name"\"
        display_double ""$((time+1))":   $song_name" "$singer_name"
        ((time=time+1))
    done
}


function downloadmusic(){
    index=$1
    ((index=index-1))
    local mid="$(eval echo \$song"$index"_mid)"
    local song="$(eval echo \$song"$index"_name)"
    local singer="$(eval echo \$song"$index"_singer)"
    curl -k -s -L "http://mobileoc.music.tc.qq.com/M500$mid.mp3?vkey=$(getvkey)&guid=FUCK&uin=0&fromtag=8" >"$music_home/$song--$singer.mp3" &
}

function getvkey(){
    request "https://c.y.qq.com/base/fcgi-bin/fcg_music_express_mobile3.fcg?g_tk=556936094&loginUin=0&hostUin=0&format=json&platform=yqq&needNewCode=0&cid=205361747&uin=0&songmid=003a1tne1nSz1Y&filename=C400003a1tne1nSz1Y.m4a&guid=FUCK"|jq -r ".data.items[0].vkey"
}

function player_music(){
    index=$1
    ((index=index-1))
    song="$(eval echo \$song"$index"_file)"
    killall play-audio >/dev/null 2>&1
    play-audio "$music_home/$song" & >/dev/null
}






#是否正在播放音乐
function playingmusic(){
    if [[ $($ps |$grep play-audio |$grep -v grep) == "" ]];then
        echo "false";
    else
        echo $($ps |$grep play-audio |$grep -v grep|$sed 's/ //g;s/.*play\-audio//g')
    fi
} 



#标题
function title(){
    display_line -
    display_line -
    display_mid "   neoterm music player   " " "
    playingmusic=$(playingmusic)
    if [[ $playingmusic == false ]];then
        display_mid "   播放音乐:暂无   " " "
    else
        display_mid "   播放音乐:$playingmusic   " " "
    fi
    display_line -
    display_line -
}


#主页面
function mainpage(){
    clear
    title
    display_mid "1: 本地乐库" -
    display_mid "2: 网络搜索" -
    display_mid "k: 停止播放" -
    display_mid "0: 退出程序" -
    read cmd
    case $cmd in
        1)
            localpage;;
        2)
            searchpage;;
        k)
            killall play-audio >/dev/null 2>&1;;
        0)
            clear
            exit;;
        *)
            mainpage;;
    esac
}

#本地音乐库页面
function localpage(){
    clear
    title
    if [[ $1 == "" ]];then
        local page=1;
        local extraindex=0;
    else 
        local page=$1
        local extraindex=$(((page-1)*10))
    fi
    if [[ $(ls $music_home) == "" ]];then
        display_mid "暂无音乐，请先下载" " "
    else
        local array=($(ls $music_home|$grep "\.mp3"|$sed 's/ /\&bps;/g'|$tr "\n" " "))
        local arraylength=${#array[@]}
        local time=0
        local songcount=10
        if [[ $arraylength -le 10 ]];then
            for element in ${array[@]};do
                element="${element//&bps;/" "}"
                local song="${element//--*/}"
                local singer="${element//*--/}"
                singer="${singer//.mp3/}"
                eval song"$time"_name=\""$song"\"
                eval song"$time"_singer=\""$singer"\"
                display_double "$((time+1)):   $song" "$singer"
            done
        else
            local time=0
            while [[ $time -lt 10 ]];do
                local element=${array[$time+$extraindex]};
                element="${element//&bps;/" "}"
                local song="${element//--*/}"
                local singer="${element//*--/}"
                singer="${singer//.mp3/}"
                eval song"$time"_name=\""$song"\"
                eval song"$time"_singer=\""$singer"\"
                eval song"$time"_file=\""$element"\"
                display_double "$((time+1)):   $song" "$singer"
                ((time=time+1))
                if [[ $((time+extraindex)) -ge arraylength ]];then
                    local hasmore=0
                    songcount=$time
                    break;
                fi
            done
            display_mid "u: 向上翻页" -
            display_mid "d: 向下翻页" -
        fi
    fi
    display_mid "x: 返回主页" -
    display_mid "0: 退出程序" -
    read cmd
    case $cmd in
        [1-9]|10)
            if [[ $cmd -gt $songcount ]];then
                localpage "$page"
            else
                player_music "$cmd"
                localpage "$page" 
            fi;;
        0)
            clear
            exit;;
        u)
            if [[ $page -le 1 ]];then
                 localpage "$page"
            else
                 ((page=page-1 ))
                 localpage "$page"
            fi;;
        d)
            if [[ $hasmore == 0 ]];then
                localpage "$page"
            else
                ((page=page+1 ))
                localpage "$page"
            fi;;
        x)
            mainpage;;
        *)
            localpage;;
    esac
}

#搜索页面
function searchpage(){
    if [[ $2 == "" ]];then
        local page=1
    else
        local page=$2
    fi
    clear
    title
    if [[ $1 == "" ]];then
        display_mid "s: 开始搜索" -
    else
        search "$1" "$page"
        display_mid "s: 新的搜索" -
        display_mid "u: 向上翻页" -
        display_mid "d: 向下翻页" -
    fi
    display_mid "x: 返回主页" -
    display_mid "0: 退出程序" -
    read cmd
    case $cmd in
        s)
            display_mid "输入关键词" -
            read keyword
            if [[ "$keyword" == "" ]];then
                searchpage
            else
                searchpage "$keyword" "$page"
            fi;;
        [1-9]|10)
            downloadmusic "$cmd"
            searchpage "$1" "$page";;
        0)
            clear
            exit;;
        u)
            if [[ $page -le 1 ]];then
                 searchpage "$1" "$page"
            else
                 ((page=page-1 ))
                 searchpage "$1" "$page"
            fi;;
        d)
            ((page=page+1 ))
            searchpage "$1" "$page";;
        x)
            mainpage;;
        *)
            searchpage "$1" "$page";;
    esac
}







mainpage