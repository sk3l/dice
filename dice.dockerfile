FROM fedora:38

MAINTAINER Admin <admin@skelton.onl>

##
# Parameterize the development account's info
ARG dev_user=dev123
ARG dev_password=dev123
ARG dev_groups=adm,wheel
ARG dev_git_user=$dev_user
ARG dev_git_mail=

##
# Define our image's packages
ENV packages="bash                \
              ca-certificates     \
              cmake               \
              curl                \
              git                 \
              gnupg               \
              golang              \
              grep                \
              hadolint            \
              jq                  \
              make                \
              nmap-ncat           \
              net-tools           \
              openssl             \
              podman              \
              python3             \
              python3-pip         \
              python3-setuptools  \
              openssh-server      \
              sed                 \
              shellcheck          \
              sudo                \
              tmux                \
              vifm                \
              which               \
              wget"

##
# Update package manager and install packages
RUN dnf -y update
RUN dnf -y install $packages
RUN dnf -y groupinstall "Development Tools" "Development Libraries"

##
# Configure and install Neovim from nightly app image
ENV   nvim_install_path=/opt/nvim
ENV   nvim_exe_path=$nvim_install_path/squashfs-root/usr/bin/nvim
ENV   nvim_source_url=https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage

RUN mkdir $nvim_install_path                        && \
    cd $nvim_install_path                           && \
    wget -O ./appImage $nvim_source_url             && \
    chmod +x $nvim_install_path/appImage            && \
    $nvim_install_path/appImage --appimage-extract  && \
    ln -s $nvim_exe_path /usr/local/sbin/nvim

##
# Install  English-language related development environment
RUN cd /opt && \
    curl -L https://raw.githubusercontent.com/languagetool-org/languagetool/master/install.sh | bash
RUN ln -s $(ls -d /opt/LanguageTool*) /opt/languagetool

##
# Setup the developer account
RUN useradd -G $dev_groups -m -s /bin/bash $dev_user -p $dev_password
RUN echo "$dev_user   ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudo-$dev_user

##
# Pivot to setup of development user
USER $dev_user
WORKDIR /home/$dev_user

##
# Setup dev user Git config
RUN git config --global --add user.name $dev_git_user
RUN if [ -n "$dev_git_mail" ]; then \
        git config --global --add user.email $dev_git_mail; \
    fi
##
# Install developer's shell resource files
# TODO - make plug-able by `RUN source <some_shell_script>`
ENV shell_rc_url=https://raw.githubusercontent.com/sk3l/sk3lshell/master/dot-files
RUN wget -O $HOME/.bashrc               $shell_rc_url/.bashrc
RUN wget -O $HOME/.bashrc_local_fedora  $shell_rc_url/.bashrc_local_fedora

RUN echo "export EDITOR=/usr/local/sbin/nvim" >> $HOME/.bashrc

##
# Install developer's tmux config file
# Customize the tmnux window/pane in 'install/entry-point.sh'
ENV shell_conf_dir=/home/$dev_user

COPY --chown=$dev_user:$dev_user install/conf/shell/.tmux.conf      $shell_conf_dir/.tmux.conf

##
# Install Neovim configuration
# TODO - make plug-able by `RUN source <some_shell_script>`
ENV editor_conf_dir=/home/$dev_user/.config/nvim
ENV editor_code_dir=$editor_conf_dir/lua
ENV editor_data_dir=/home/$dev_user/.local/share/nvim

COPY --chown=$dev_user:$dev_user install/conf/nvim/conf/init.vim     $editor_conf_dir/init.vim
COPY --chown=$dev_user:$dev_user install/conf/nvim/conf/ale.vim      $editor_conf_dir/ale.vim
COPY --chown=$dev_user:$dev_user install/conf/nvim/conf/nerdtree.vim $editor_conf_dir/nerdtree.vim
COPY --chown=$dev_user:$dev_user install/conf/nvim/code/plugins.lua  $editor_code_dir/plugins.lua

##
# Bootstrap Neovim's packages via packer.nvim
RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

RUN echo "colorscheme duskfox" > $editor_conf_dir/colors.vim

##
# Setup Bash-related development environment
RUN pip3 install --user bashate

##
# Setup Python-related development environment
ENV python_tools="python-lsp-server pylint flake8 jedi mypy black isort proselint"
RUN pip3 install --user $python_tools

##
# Setup Go-related development environment
RUN go install golang.org/x/tools/gopls@latest

##
# Setup node.js version manager (NVM) and related node packages
SHELL ["/bin/bash", "-c"]
ENV node_packages="write-good"
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
RUN source $HOME/.nvm/nvm.sh && nvm install node && npm install $node_packages

WORKDIR /home/$dev_user
COPY install/entry-point.sh /entry-point.sh
ENTRYPOINT ["/entry-point.sh"]
