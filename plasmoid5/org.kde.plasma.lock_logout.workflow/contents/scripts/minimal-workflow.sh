#!/bin/bash

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/plasma-power-workflow"
mkdir -p "$STATE_DIR"

update_status() {
    cat > "$STATE_DIR/$1.json" << EOF
$2
EOF
}

case "$1" in

start)

    ID=$(date +%s)-$$

    (
        for p in $(seq 0 99); do

            update_status "$ID" \
"{\"id\":\"$ID\",\"state\":\"running\",\"on_error\":\"terminate\",\"workflow_name\":\"Minimal Workflow\",\"step_name\":\"Demo Delay\",\"step_current\":1,\"step_total\":1,\"step_percent\":$p,\"workflow_percent\":$p}"

            sleep 0.6

        done

        update_status "$ID" \
"{\"id\":\"$ID\",\"state\":\"error\",\"on_error\":\"terminate\",\"message\":\"Please configure a real workflow script in the plasmoid settings.\"}"

    ) &

    echo "{\"id\":\"$ID\",\"on_error\":\"terminate\"}"
    ;;

status)

    if [ -f "$STATE_DIR/$2.json" ]; then
        cat "$STATE_DIR/$2.json"
    else
        echo '{"state":"error","message":"Unknown workflow ID"}'
        exit 1
    fi
    ;;

cancel)

    update_status "$2" \
'{"id":"'"$2"'","state":"cancelled"}'
    ;;

*)

    echo "Usage:"
    echo "  $0 start shutdown|reboot|logout"
    echo "  $0 status <id>"
    echo "  $0 cancel <id>"
    exit 1
    ;;

esac
