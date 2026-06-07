```bash
#!/bin/bash

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/plasma-power-workflow"
mkdir -p "$STATE_DIR"

case "$1" in

start)
    ID=$(date +%s)-$$

    (
        echo '{"id":"'"$ID"'","state":"running","on_error":"terminate","workflow_name":"Minimal Example"}' \
            > "$STATE_DIR/$ID.json"

        sleep 5

        echo '{"id":"'"$ID"'","state":"success"}' \
            > "$STATE_DIR/$ID.json"
    ) &

    echo '{"id":"'"$ID"'","on_error":"terminate"}'
    ;;

status)
    cat "$STATE_DIR/$2.json"
    ;;

cancel)
    echo '{"id":"'"$2"'","state":"cancelled"}' \
        > "$STATE_DIR/$2.json"
    ;;
esac
```

