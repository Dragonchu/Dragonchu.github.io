# 如何方便地阅读Arduino或Esp8266的源代码

date: April 27, 2022
description: 本文介绍如何使用ArduinoCLI生成compile_commands.json从而更好地阅读Arduino以及Esp8266的代码。
inList: No
inMenu: No
publish: Yes
tags: 嵌入式开发, 归档
template: post

# **如何方便地阅读Arduino或Esp8266的源代码**

# **Windows（Sourcetrail+ArduinoCLI）**

## **需要用到的工具**

- [Sourcetrail](https://github.com/CoatiSoftware/Sourcetrail)
- [ArduinoCLI](https://github.com/arduino/arduino-cli)

根据[官方手册](https://arduino.github.io/arduino-cli/0.21/installation/)，下载[windows下的压缩包](https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Windows_64bit.zip)，解压后的文件夹种有一个**arduino-cli.exe**，执行文件。假设改执行文件的路径为**D:\arduino-cli\arduino-cli.exe**，用管理员权限打开cmd进入该目录。

## **Arduino**

根据[官方手册](https://arduino.github.io/arduino-cli/0.21/getting-started/)，先使用`arduino-cli core update-index`更新一下缓存。将Arduino的板子插入电脑的接口后，使用`arduino-cli board list`后，**core**会告知改板子使用的核心，比如我用的Arduino UNO R3，**core**是**arduino:avr**，那么需要下载该core`arduino-cli core install arduino:avr`，如果这个时候出现**Access  is denied**错误，根据[issues723](https://github.com/arduino/arduino-cli/issues/723)，关闭一下杀毒软件在尝试一次（我使用的火绒导致静默阻止）。core安装成功之后可以使用`arduino-cli core list`查看一下所有已经安装的core。其他使用方法可以参考官方文档，重点是如何更好地阅读代码。假设我们要阅读的代码是**MyFirstSketch.ino**，那么根据[官方手册](https://arduino.github.io/arduino-cli/0.21/commands/arduino-cli_compile/)可以执行`arduino-cli compile -b esp8266:esp8266:nodemcu HttpOTA --only-compilation-database -v`，**--only-compilation-database**会在build目录下生成**comile_commands.json**文件，-v会显示具体的信息，而build目录就是输出最后arduino-sketch文件所在的目录。

找到comile_commands.json文件后就可以直接用Sourcetrail打开，创建新项目时选择CDB，里面选择comile_commands.json文件（建议复制到源文件目录下，sourcetrail的项目文件也选择源文件目录），解析头文件选择从cdb中导入就行，这样解析之后虽然还会有一些error和fatal，但是基本上不影响源码阅读。

## **esp8266**

方法和Arduino使用差不多，根据[官方手册](https://arduino.github.io/arduino-cli/0.21/configuration/)安装esp8266的库文件用这个命令
`arduino-cli core update-index --additional-urls https://arduino.esp8266.com/stable/package_esp8266com_index.json`
注意连接板子查看具体的board型号。

# **WSL2**

加入需要在Windows上的WSL2里面使用ArduinoCLI，vscode使用compile_command.json来解析的话，会遇到下面一些问题。

WSL2目前不支持串口映射，解决办法时根据[微软的手册](https://docs.microsoft.com/en-us/windows/wsl/connect-usb)安装软件进行手动映射。

在Linux环境中遇到avrdude: ser_open(): can't open device "/dev/ttyACM0": Permission denied问题，`sudo chmod a+rw /dev/ttyACM0`

```
arduino-cli core install esp8266:esp8266
arduino-cli compile -b esp8266:esp8266:nodemcu HttpOTA --only-compilation-database -v
C:\Users\18454\AppData\Local\Temp\arduino-sketch-776950451AE70DA4FF60E70254F9E1B8
```