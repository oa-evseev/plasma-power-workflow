#!/bin/bash

case "$1" in
    start)
        echo '{"id":"invalid"}'
        ;;
    status)
        echo '{ definitely broken json'
        ;;
    cancel)
        echo '{"state":"cancelled"}'
        ;;
esac
