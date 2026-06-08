#!/bin/bash

case "$1" in
    start)
        echo '{"id":"success"}'
        ;;
    status)
        echo '{
            "state":"success",
            "message":"Completed successfully"
        }'
        ;;
    cancel)
        echo '{"state":"cancelled"}'
        ;;
esac
