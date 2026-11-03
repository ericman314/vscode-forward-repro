#!/bin/sh
# Run on the host while serve.sh is running in the container.
# Fetches the file in parallel through VS Code's forwarded port, then from
# inside the container, and counts complete and truncated downloads.
PARALLEL=${PARALLEL:-40}
RUNS=${RUNS:-3}
EXPECTED=1000000

if ! command -v docker >/dev/null; then
  echo "docker not found. Run this on the host, not in the dev container." >&2
  exit 1
fi

container=$(docker ps -q --filter "label=devcontainer.local_folder=$(cd "$(dirname "$0")" && pwd)")
if [ -z "$container" ]; then
  echo "Dev container not found. Open this folder in VS Code with Reopen in Container." >&2
  exit 1
fi

fetch() {  # $1 = command prefix ("" for host, "docker exec ..." for container)
  i=0
  while [ "$i" -lt "$PARALLEL" ]; do
    $1 curl -s -o /dev/null -w '%{size_download}\n' http://localhost:8000/big.bin &
    i=$((i + 1))
  done
  wait
}

report() {  # $1 = label, $2 = command prefix
  ok=0 short=0 r=0
  while [ "$r" -lt "$RUNS" ]; do
    for size in $(fetch "$2"); do
      if [ "$size" -eq "$EXPECTED" ]; then ok=$((ok + 1)); else short=$((short + 1)); echo "  truncated: $size bytes"; fi
    done
    r=$((r + 1))
  done
  echo "$1: $ok complete, $short truncated"
}

report "Through VS Code forwarded port" ""
report "Inside the container (no forwarder)" "docker exec $container"
