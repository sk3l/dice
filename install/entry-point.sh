#!/bin/bash

tmux -2 new-session -s DICE -d  -n "local" -c ~/
tmux -2 split-window  -v -c ~/ -t 1
tmux -2 split-window  -v -c ~/ -t 2 vifm
tmux -2 kill-pane -t 1

tmux -2 new-window -n "code"    -c ~/
tmux -2 new-window -n "build"   -c ~/
tmux -2 new-window -n "test"    -c ~/
tmux -2 new-window -n "run"     -c ~/

tmux -2 select-window -t 1

tmux attach-session -t DICE 


