#!/bin/bash

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/plasma-power-workflow"
mkdir -p "$STATE_DIR"

update_status() {
    cat > "$STATE_DIR/$ID.json" << EOF
$1
EOF
}

run_step() {
    local NAME="$1"
    local CURRENT="$2"
    local TOTAL="$3"
    local START="$4"
    local END="$5"
    local DELAY="$6"

    for p in $(seq 0 100); do
        local workflow_percent=$((START + (END - START) * p / 100))

        update_status "$(cat << EOF
{"id":"$ID","state":"running","on_error":"$ON_ERROR","workflow_name":"Example Workflow","step_name":"$NAME","step_current":$CURRENT,"step_total":$TOTAL,"step_percent":$p,"workflow_percent":$workflow_percent}
EOF
)"

        sleep "$DELAY"
    done
}

COMMAND="$1"

case "$COMMAND" in

start)
    ACTION="$2"

    ID=$(date +%s)-$$

    case "$ACTION" in
        shutdown)
            ON_ERROR="terminate"
            ;;
        reboot)
            ON_ERROR="terminate"
            ;;
        logout)
            ON_ERROR="proceed"
            ;;
        *)
            echo '{"error":"Unknown action"}'
            exit 1
            ;;
    esac

    (
        run_step "Initialisation" 1 3 0 15 0.05
        run_step "Long Operation" 2 3 15 85 0.10
        run_step "Verification" 3 3 85 100 0.03

        case "$ACTION" in

            shutdown)
                update_status \
'{"id":"'"$ID"'","state":"success","workflow_percent":100}'
                ;;

            reboot)
                update_status \
'{"id":"'"$ID"'","state":"error","on_error":"terminate","message":"Example critical failure"}'
                ;;

            logout)
                update_status \
'{"id":"'"$ID"'","state":"error","on_error":"proceed","message":"Example non-critical failure"}'
                ;;
        esac

    ) &

    echo "{\"id\":\"$ID\",\"on_error\":\"$ON_ERROR\"}"
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
    update_status \
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
