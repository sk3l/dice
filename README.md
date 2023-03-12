<h1 align="center">
<img src="https://user-images.githubusercontent.com/4662876/224566650-a840d55d-e015-44e1-b755-d5b3acc6bb2f.png" alt="dice">
     <div><strong>dice</strong></div>
</h1>

`dice` is an acronym for the term "Development Integrated Container Environment". It's a set of scripts and files that, when combined, provider a Dockerized IDE-like experience, which contains all the tools and utilities a developer needs in their coding toolkit.

**Features**
- portable
  - runs anywhere you can put Docker and GNU Make
- convenient
  - run it without Docker knowledge using GNU MAKE commands
- smart
  - eliminates tracking differing package names for the package manager serving your host system
- configurable
  - customize user name, editor, shell, etc

## What it contains:
The building blocks `dice` is assembled from include:
- tmux
- compilers and run-time environments:
  - C/C++
  - Golang
  - Python
  - Node.JS
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


