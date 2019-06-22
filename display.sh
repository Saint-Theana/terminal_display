#!/usr/bin/bash

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
    alltext=$(echo "$1"|$sed 's/ /g/g')
    alltext=$(echo "$alltext" |$tr -d "\n" |$od -An -c|$sed 's/[0-9]\{3\} [0-9]\{3\} [0-9]\{3\}/gg/g'|$tr -d " ")
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
    echo "$1$(produce $centerlength "$3")$2"
}


display_line -
display_line -
display_line -
display_line -
display_line -
display_line -
display_side "Tick" "Tick" " "
display_side "Tick" "Tick" "%"
display_side "Tick" "Tick" "@"
display_side "Tick" "Tick" " "
display_side "Tick" "Tick" " "
display_side "Tick" "Tick" " "
display_mid "Tick Tock" -
display_mid "大帅逼！" -
display_mid "大帅逼！" " "
display_mid "大帅逼！" -
display_line "帅"
display_line "帅"
display_line "帅"
display_line "帅"
display_line "帅"
display_line "帅"
display_line "帅"
display_line "帅"
display_double "Tick Tock" "最帅" " "
display_double "Tick Tock" "最帅" " "
display_double "Tick Tock" "最帅" " "
display_double "Tick Tock" "最帅" " "
display_double "Tick Tock" "最帅" " "
display_double "Tick Tock" "最帅" " "
display_double "Tick Tock" "最帅" " "
display_double "Tick Tock" "最帅" " "