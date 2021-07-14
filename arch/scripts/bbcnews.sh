#!/bin/bash
set -e

# Download bbcnews audio from putclub.com
#
# 1. Download today's news.
# ./bbcnews
# 
# 2. Download news for a given day.
# ./bbcnews 20210408
# 
# 3. Download news within a date range.
# ./bbcnews 20210408 20210508

if [ "$1" == "" ]; then
    yyyymm=$(date '+%Y%m')
    dd=$(date '+%d')
    mmdd="${yyyymm:4:2}$dd"
    http_proxy="" https_proxy="" \
        curl "http://download.putclub.com/newupdate/sest/${yyyymm}/${dd}/putclub.com_${yyyymm}${dd}BBC.mp3" \
        -o "$HOME/devel/news/audio/${yyyymm}${dd}BBC.mp3"
    tageditor set title="$mmdd" artist="BBC World News" album="Two Minutes" comment="" -f "$HOME/devel/news/audio/${yyyymm}${dd}BBC.mp3"

    read -r -p "open downloaded audio using mpv? (Y/n)" open_audio
    case $open_audio in
        Y): 
            mpv "$HOME/devel/news/audio/${yyyymm}${dd}BBC.mp3"
            ;;
        n|*):
            ;;
    esac
elif [ "$2" == "" ]; then
    yyyymm=${1:0:6}
    dd=${1:6:2}
    mmdd=${1:4:4}
    http_proxy="" https_proxy="" \
        curl "http://download.putclub.com/newupdate/sest/${yyyymm}/${dd}/putclub.com_${yyyymm}${dd}BBC.mp3" \
        -o "$HOME/devel/news/audio/${yyyymm}${dd}BBC.mp3"
    tageditor set title="$mmdd" artist="BBC World News" album="Two Minutes" comment="" -f "$HOME/devel/news/audio/${yyyymm}${dd}BBC.mp3"

else
    startdate=$1
    enddate=$2

    dates=()
    for (( date="$startdate"; date <= enddate; )); do
        dates+=( "$date" )
        date="$(date --date="$date + 1 days" +'%Y%m%d')"
    done

    for date in "${dates[@]}"; do
        yyyymm=${date:0:6}
        dd=${date:6:2}
        mmdd=${date:4:4}
        http_proxy="" https_proxy="" \
            curl "http://download.putclub.com/newupdate/sest/${yyyymm}/${dd}/putclub.com_${yyyymm}${dd}BBC.mp3" \
            -o "$HOME/devel/news/audio/${yyyymm}${dd}BBC.mp3"
        tageditor set title="$mmdd" artist="BBC World News" album="Two Minutes" comment="" -f "$HOME/devel/news/audio/${yyyymm}${dd}BBC.mp3"
    done
fi
