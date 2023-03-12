#!/bin/bash

tmux -2 new-session -s DICE -d  -n "local" -c ~/code/
tmux -2 split-window  -v -c ~/code/ -t 1
tmux -2 split-window  -v -c ~/code/ -t 2 vifm
#tmux -2 kill-pane -t 1

tmux -2 new-window -n "code"    -c ~/code/
tmux -2 new-window -n "build"   -c ~/code/
tmux -2 new-window -n "test"    -c ~/code/
tmux -2 new-window -n "run"     -c ~/code/

tmux -2 select-window -t 1

tmux attach-session -t DICE 


