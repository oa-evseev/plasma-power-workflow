#!/bin/bash

case "$1" in
    start)
        echo '{"id":"cancelled"}'
        ;;
    status)
        echo '{
            "state":"cancelled",
            "message":"Cancelled by workflow"
        }'
        ;;
    cancel)
        echo '{"state":"cancelled"}'
        ;;
esac
