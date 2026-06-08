#!/bin/bash

case "$1" in
    start)
        echo '{"id":"terminate"}'
        ;;
    status)
        echo '{
            "state":"error",
            "message":"Critical error",
            "on_error":"terminate"
        }'
        ;;
    cancel)
        echo '{"state":"cancelled"}'
        ;;
esac
