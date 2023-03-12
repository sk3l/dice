# dice
**Development Integrated Container Environment**

## What is it?
This is a set of scripts and files for Docker-izing an IDE-like experience using:
- tmux
- NeoVim
- ALE LSP
- language-specific LSP plugins, e.g. clangd

## How do I use it?
Invoke the top-level Makefile target  to create your Docker base image.
```bash
$> make build 
```

Then, you can use `make run` to run an ephemeral container based off your images. Similrarly, use `make create` to create a persistent container, which you can start/stop (and attach to it via `docker exec -it [container-name] /bin/bash`).

You can control where your _DICE_ is pointing to (i.e. which project it's opening) by customizing the `PROJ_NAME' and `PROJ_DIR` make vars
```bash
$> make run-py PROJ_NAME=my_cool_project PROJ_DIR=/path/to/my/proj/source
```
This will land you at a Bash shell in the $dev_user's $HOME directory by default. You can then run tmux, and access your source directory at the container path `/source`

## TODO
- templatize dev user $HOME contents, dot files, tmux conf, etc
- more options around project editing, path, build/lint/debug integration, etc
- more options around Docker image construction and configuration


