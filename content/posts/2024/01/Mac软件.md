---
title: "记录一下我Mac上安装的一些工具"
date: 2024-02-08
draft: false
tags: ["mac"]
---

## 全局包管理工具
brew

## python (system)
pyenv(install by brew)
```sh
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
```
poetry(install by brew)
poetry install
poetry env remove 3.12

## go (install with official installer)

## warp (终端)
