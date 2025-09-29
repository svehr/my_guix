#!/bin/sh

config_dir="${HOME}/my_guix"
config="config/system/slimbook.scm"

function usage {
    echo "available commands:"
    echo "  * reconfigure"
    echo "  * vm"
    exit 1
}

if [ $# -lt 1 ]; then
    usage >&2
    exit 1
fi

command="$1"
shift 1

function reconfigure {
    cd "$config_dir" && sudo guix system -L . reconfigure "$config" && sudo guix-copy-to-boot
}

function vm {
    cd "$config_dir" && guix system -L . vm "$config" --full-boot
}


case "$command" in
    reconfigure)
        reconfigure
        ;;
    vm)
        vm
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac
