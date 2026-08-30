#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt install -y git
sudo apt install -y zsh


# Set default environment to zsh
sudo chsh -s "$(command -v zsh)" "$USER"


curl https://mise.run | sh
~/.local/bin/mise use --global uv
~/.local/bin/mise use --global python
~/.local/bin/mise install


rm -rf ~/.git
git init ~
git -C ~ remote add origin https://github.com/carlba/dotfiles.git
git -C ~ fetch origin
git -C ~ checkout -t origin/main -f
rm -rf ~/.git

sudo apt install -y gh
gh auth login --git-protocol https
gh auth setup-git

git clone https://github.com/carlba/ansible-monorepo.git
cd ansible-monorepo
~/.local/bin/mise exec -- uv sync

touch ~/.vault_pass.txt
chmod 600 ~/.vault_pass.txt

if [ ! -s ~/.vault_pass.txt ]; then
  read -rsp "Enter ansible-vault password: " vault_pass < /dev/tty
  echo
  printf '%s' "$vault_pass" > ~/.vault_pass.txt
fi

~/.local/bin/mise exec -- uv run ansible-playbook -l malinux --tags common playbook.yml

