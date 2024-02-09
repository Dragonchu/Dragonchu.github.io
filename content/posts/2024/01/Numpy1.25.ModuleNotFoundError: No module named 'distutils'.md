---
title: "python3.12安装numpy1.25.2不兼容问题"
date: 2024-02-04
draft: false
tags: ["leetCode"]
---

```sh
• Installing numpy (1.25.2): Failed

  ChefBuildError

  Backend 'setuptools.build_meta:__legacy__' is not available.
  
  Traceback (most recent call last):
    File "/opt/homebrew/Cellar/poetry/1.7.1/libexec/lib/python3.12/site-packages/pyproject_hooks/_in_process/_in_process.py", line 77, in _build_backend
      obj = import_module(mod_path)
            ^^^^^^^^^^^^^^^^^^^^^^^
    File "/opt/homebrew/Cellar/python@3.12/3.12.1_1/Frameworks/Python.framework/Versions/3.12/lib/python3.12/importlib/__init__.py", line 90, in import_module
      return _bootstrap._gcd_import(name[level:], package, level)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "<frozen importlib._bootstrap>", line 1387, in _gcd_import
    File "<frozen importlib._bootstrap>", line 1360, in _find_and_load
    File "<frozen importlib._bootstrap>", line 1310, in _find_and_load_unlocked
    File "<frozen importlib._bootstrap>", line 488, in _call_with_frames_removed
    File "<frozen importlib._bootstrap>", line 1387, in _gcd_import
    File "<frozen importlib._bootstrap>", line 1360, in _find_and_load
    File "<frozen importlib._bootstrap>", line 1331, in _find_and_load_unlocked
    File "<frozen importlib._bootstrap>", line 935, in _load_unlocked
    File "<frozen importlib._bootstrap_external>", line 994, in exec_module
    File "<frozen importlib._bootstrap>", line 488, in _call_with_frames_removed
    File "/private/var/folders/sk/ldq44t9j7735_tpmvr3hzjh80000gn/T/tmp0z5pdhdq/.venv/lib/python3.12/site-packages/setuptools/__init__.py", line 10, in <module>
      import distutils.core
  ModuleNotFoundError: No module named 'distutils'
  

  at /opt/homebrew/Cellar/poetry/1.7.1/libexec/lib/python3.12/site-packages/poetry/installation/chef.py:164 in _prepare
      160│ 
      161│                 error = ChefBuildError("\n\n".join(message_parts))
      162│ 
      163│             if error is not None:
    → 164│                 raise error from None
      165│ 
      166│             return path
      167│ 
      168│     def _prepare_sdist(self, archive: Path, destination: Path | None = None) -> Path:

Note: This error originates from the build backend, and is likely not a problem with poetry but with numpy (1.25.2) not supporting PEP 517 builds. You can verify this by running 'pip wheel --no-cache-dir --use-pep517 "numpy (==1.25.2)"'.
```

我遇到了同样的问题，这是我的系统以及相关工具的版本

System Version: macOS 13.6.4
Kernel Version: Darwin 22.6.0
Homebrew 4.2.5
Poetry (version 1.7.1)
pip 21.2.3

通过我的实验，我发现python3.12版本和numpy1.25.2版本具有冲突。
而将python版本降低到3.10可以解决这个问题。

我最终使用了pyenv来进行python版本的切换

```
brew install pyenv
```

[根据官方文档配置shell环境](https://github.com/pyenv/pyenv?tab=readme-ov-file#set-up-your-shell-environment-for-pyenv)

重启终端生效后, 安装python3.10.0
```
pyenv install 3.10.0
```
切换python版本
```
pyenv local 3.10.0
```
或者
```
pyenv global 3.10.0
```

确认版本切换生效后记得将poetry项目的python虚拟环境切换到3.10.0
```
poetry env use 3.10.0
```

I have encountered the same issue, and here are the versions of my system and related tools:

System Version: macOS 13.6.4

Kernel Version: Darwin 22.6.0

Homebrew 4.2.5

Poetry (version 1.7.1)

pip 21.2.3

Through my experimentation, I found a conflict between Python 3.12 and numpy 1.25.2 versions. Lowering the Python version to 3.10 resolves the issue.

I ultimately used pyenv to switch Python versions:
```
brew install pyenv
```

[Configure the shell environment according to the official documentation.](https://github.com/pyenv/pyenv?tab=readme-ov-file#set-up-your-shell-environment-for-pyenv)

After restarting the terminal to apply changes, install Python 3.10.0:
```
pyenv install 3.10.0
```
Switch Python version:
```
pyenv local 3.10.0
```
or
```
pyenv global 3.10.0
```

After confirming the version switch, remember to switch the Python virtual environment of the Poetry project to 3.10.0:

```
poetry env use 3.10.0
```

