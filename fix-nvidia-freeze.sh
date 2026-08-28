#!/usr/bin/env bash
set -euo pipefail

services=(
    "systemd-suspend"
    "systemd-hibernate"
    "systemd-hybrid-sleep"
    "systemd-suspend-then-hibernate"
)

for s in "${services[@]}"; do
    target_dir="/etc/systemd/system/${s}.service.d"
    mkdir -p "$target_dir"
    ln -sf /dev/null "${target_dir}/10-nvidia-no-freeze-session.conf"
done

systemctl daemon-reload
