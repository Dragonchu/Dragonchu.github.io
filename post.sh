#!/bin/bash

# 检查是否提供了参数
if [ -z "$1" ]; then
  echo "请提供一个参数作为文件名"
  exit 1
fi

# 获取当前目录
current_dir=$(pwd)

# 检查并创建 content/posts 文件夹
if [ ! -d "$current_dir/content/posts" ]; then
  mkdir -p "$current_dir/content/posts"
fi

# 获取当前时间的年份和月份
year=$(date +%Y)
month=$(date +%m)

# 检查并创建 content/posts/年/月 文件夹
if [ ! -d "$current_dir/content/posts/$year/$month" ]; then
  mkdir -p "$current_dir/content/posts/$year/$month"
fi

# 使用 hugo new 命令创建新的内容文件
hugo new "content/posts/$year/$month/$1.md"
