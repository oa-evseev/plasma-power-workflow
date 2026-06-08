#!/bin/bash

case "$1" in
    start)
        echo '{"id":"running"}'
        ;;
    status)
        echo '{
            "state":"running",
            "workflow_name":"Long workflow",
            "step_name":"Still working",
            "workflow_percent":50,
            "step_percent":75
        }'
        ;;
    cancel)
        echo '{"state":"cancelled"}'
        ;;
esac
