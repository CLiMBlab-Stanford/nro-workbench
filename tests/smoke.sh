#!/bin/sh
set -eu

version=$(wb_command -version)
printf '%s\n' "$version" | grep -F "Version: ${WORKBENCH_VERSION}"

command_libraries=/opt/workbench/libs_linux64:/opt/workbench/libs_linux64/osmesa
viewer_libraries=/opt/workbench/libs_linux64
command_missing=$(LD_LIBRARY_PATH="$command_libraries" \
    ldd /opt/workbench/exe_linux64/wb_command | grep "not found" || true)
viewer_missing=$(LD_LIBRARY_PATH="$viewer_libraries" \
    ldd /opt/workbench/exe_linux64/wb_view | grep "not found" || true)
if [ -n "$command_missing$viewer_missing" ]; then
    printf '%s\n%s\n' "$command_missing" "$viewer_missing" >&2
    exit 1
fi

Xvfb :99 -screen 0 1280x1024x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &
xvfb_pid=$!
trap 'kill "$xvfb_pid" 2>/dev/null || true' EXIT INT TERM
export DISPLAY=:99
sleep 1
wb_view >/tmp/wb-view.log 2>&1 &
viewer_pid=$!
sleep 8
if ! kill -0 "$viewer_pid" 2>/dev/null; then
    wait "$viewer_pid" || true
    cat /tmp/wb-view.log >&2
    exit 1
fi
kill "$viewer_pid"
wait "$viewer_pid" || true
