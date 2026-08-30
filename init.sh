#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    DIST="darwin"
    ;;
  Linux)
    . /etc/os-release
    DIST="$ID"
    ;;
esac

if [[ "$DIST" == 'debian' || "$DIST" == 'ubuntu' ]]; then
  sudo apt update
  sudo apt install -y git zsh
elif [[ "$DIST" == 'darwin' ]]; then
  brew install git zsh
fi


curl https://mise.run | sh
eval "$($HOME/.local/bin/mise activate $(basename $SHELL))"
mise use --global uv python gh
mise install

gh auth login --git-protocol ssh && gh auth setup-git

git clone https://github.com/carlba/ansible-monorepo.git
cd ansible-monorepo
mise exec -- uv sync

touch ~/.vault_pass.txt && chmod 600 ~/.vault_pass.txt

if [ ! -s ~/.vault_pass.txt ]; then
  read -rsp "Enter ansible-vault password: " vault_pass < /dev/tty
  echo
  printf '%s' "$vault_pass" > ~/.vault_pass.txt
fi

mise exec -- uv run ansible-playbook -l malinux --tags common playbook.yml

