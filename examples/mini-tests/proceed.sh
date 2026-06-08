#!/bin/bash

case "$1" in
    start)
        echo '{"id":"proceed"}'
        ;;
    status)
        echo '{
            "state":"error",
            "message":"Non-critical error",
            "on_error":"proceed"
        }'
        ;;
    cancel)
        echo '{"state":"cancelled"}'
        ;;
esac
