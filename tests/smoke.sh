#!/bin/sh
set -eu

version=$(wb_command -version)
printf '%s\n' "$version" | grep -F "Version: ${WORKBENCH_VERSION}"

for executable in /opt/workbench/exe_linux64/wb_command /opt/workbench/exe_linux64/wb_view; do
    missing=$(LD_LIBRARY_PATH=/opt/workbench/libs_linux64 ldd "$executable" | grep "not found" || true)
    if [ -n "$missing" ]; then
        printf '%s\n' "$missing" >&2
        exit 1
    fi
done

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
