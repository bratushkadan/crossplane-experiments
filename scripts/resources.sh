#!/usr/bin/env bash

source "$PWD/.yc.env"

case $1 in
    start)
        echo "starting..."
        echo "k8s node group: ${K8S_NODE_GROUP}"
        ;;
    stop)
        echo "stopping..."
        ;;
    *)
        echo "unknown subcommand $1, available commands are: \"start\", \"stop\""
        exit 1
        ;;
esac
