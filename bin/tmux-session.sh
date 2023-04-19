#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$SCRIPT_DIR/..
cd $ROOT_DIR

session=public-party-canton

set -euC

daml build

att() {
    [ -n "${TMUX:-}" ] &&
        tmux switch-client -t "=$session" ||
        tmux attach-session -t "=$session"
}

if tmux has-session -t "=${session}" 2>/dev/null; then
    att
    exit 0
fi

tmux new-session -d -s $session

window=0
tmux rename-window -t $session:$window 'docker compose' \; \
     send-keys     -t $session:$window 'sleep 10' C-m \; \
     send-keys     -t $session:$window 'docker compose logs -f' C-m \; \

window=1
tmux new-window   -t $session:$window -n 'central' \; \
     send-keys    -t $session:$window.0 'docker compose up central -d' C-m \; \
     send-keys    -t $session:$window.0 'docker attach central' C-m \; \


window=2
tmux new-window   -t $session:$window -n 'traderOne' \; \
     send-keys    -t $session:$window.0 'docker compose up traderOne -d && docker attach traderOne' \; \
     select-pane  -t $session:$window.0


window=3
tmux new-window   -t $session:$window -n 'commands'

att
