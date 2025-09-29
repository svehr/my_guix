#!/bin/sh
config_dir="${HOME}/my_guix"
# NOTE: in case of no internet:
#       pass `--no-substitutes` to avoid connecting to the internet
cd "${config_dir}" && guix home -L . reconfigure config/home/home.scm "$@"
