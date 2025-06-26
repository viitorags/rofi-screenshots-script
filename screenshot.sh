#!/usr/bin/env bash

dir="$HOME/.config/rofi"
dir_screenshot="$HOME/Pictures/Screenshots/"
theme="screenshot"

host=$(hostname)

option_0="󰇄  Capture Desktop"
option_1="󰹑  Capture Area"
option_2="  Capture current window"
option_3="  Capture in 5s"
option_4="  Record Desktop"
option_5="󱣴  Record Area"
option_6="󰓛  Stop Recording"

rofi_cmd() {
    rofi -dmenu \
        -p "$USER@$host" \
        -mesg "  $dir_screenshot" \
        -theme ${dir}/${theme}.rasi
}

run_rofi() {
    echo -e "$option_0\n$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

run_cmd() {
    if [[ $1 == '--option_0' ]]; then
        sleep 0.3 && grim $(xdg-user-dir)/Pictures/Screenshots/$(date +'%s_grim.png')
        notify-send -i camera -t 1000 "Screenshot saved" "Location: ${dir_screenshot}"
    elif [[ $1 == '--option_1' ]]; then
        sleep 0.3 && grim -g "$(slurp)" $(xdg-user-dir)/Pictures/Screenshots/$(date +'%s_grim.png')
        notify-send -i camera -t 1000 "Area screenshot saved" "Location: ${dir_screenshot}"
    elif [[ $1 == '--option_2' ]]; then
        coords=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        sleep 0.3 && grim -g "$coords" $(xdg-user-dir)/Pictures/Screenshots/$(date +'%s_grim.png')
        notify-send -i camera -t 1000 "Window screenshot saved" "Location: ${dir_screenshot}"
    elif [[ $1 == '--option_3' ]]; then
        sleep 5 && grim $(xdg-user-dir)/Pictures/Screenshots/$(date +'%s_grim.png')
        notify-send -i camera -t 1000 "Delayed screenshot saved" "Location: ${dir_screenshot}"
    elif [[ $1 == '--option_4' ]]; then
        notify-send -i media-record -t 1000 "Recording started" "Saving to Videos folder"
        sleep 1 && wf-recorder -f "$HOME/Videos/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4" \
            -c libx264rgb \
            --audio &
    elif [[ $1 == '--option_5' ]]; then
        notify-send -i media-record -t 1000 "Area recording started" "Saving to Videos folder"
        sleep 1 && wf-recorder -g "$(slurp)" -f "$HOME/Videos/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4" \
            -c libx264rgb \
            --audio &
    elif [[ $1 == '--option_6' ]]; then
        if pgrep wf-recorder >/dev/null; then
            pkill wf-recorder
            notify-send -i media-playback-stop -t 1000 "Recording stopped"
        else
            notify-send -i dialog-warning -t 1000 "No recording in progress"
        fi
    else
        exit 0
    fi
}

chosen="$(run_rofi)"
case ${chosen} in
$option_0)
    run_cmd --option_0
    ;;
$option_1)
    run_cmd --option_1
    ;;
$option_2)
    run_cmd --option_2
    ;;
$option_3)
    run_cmd --option_3
    ;;
$option_4)
    run_cmd --option_4
    ;;
$option_5)
    run_cmd --option_5
    ;;
$option_6)
    run_cmd --option_6
    ;;
esac
