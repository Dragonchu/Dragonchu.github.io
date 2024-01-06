---
title: "OpenCV的安装与环境配置（window10，Visual Studio 2019）"
date: 2022-04-17
draft: false
tags: ["归档","环境配置"]
---


# **OpenCV的安装与环境配置（window10，Visual Studio 2019）**

日期：2021年04月17日

## **OpenCV的安装**

**第一步：**下载OpenCv **[https://opencv.org/releases/](https://opencv.org/releases/)**，本文使用 OpenCV-4.5.0 。

**第二步：**下载得到 opencv-4.5.0-vc14_vc15.exe 文件，运行该文件，选择解压到目标地址，本文解压到目录 D:\Library 。

**第三步：**为了方便以及清晰，这一步添加系统环境变量 OPENCV_DIR 。方法为以管理员身份运行 cmd ，输入并运行命令`setx -m OPENCV_DIR D:\Library\opencv\build\x64\vc15`，（此处根据平台环境可能需要有所调整）。

**第四步：**添加系统环境变量Path中的环境变量，添加**%OPENCV_DIR%\bin**

## **Visual Studio 2019项目的配置**

- 解决方案配置为 Debug ，解决方案平台为 x64 。
- 项目属性 - VC++ 目录 - 包含目录，添加 D:\Library\opencv\build\include 路径
- 项目属性 - VC++ 目录 - 库目录，添加 D:\Library\opencv\build\x64\vc15\lib 路径
- 项目属性 - 链接器 - 输入 - 附加依赖项，添加 opencv_world450d.lib ，（此处lib文件可在 D:\Library\opencv\build\x64\vc15\bin 中查看，d表示debug，解决方案与平台需要根据实际情况做调整）

## **测试程序**

```cpp
#include <iostream>
#include <stdio.h>
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
using namespace std;
using namespace cv;

int main()
{
  // 设置窗口
  Mat img = Mat::zeros(Size(800, 600), CV_8UC3);

  img.setTo(255);              // 设置屏幕为白色
  Point p1(100, 100);          // 点p1
  Point p2(758, 50);           // 点p2

  // 画直线函数
  line(img, p1, p2, Scalar(0, 0, 255), 2);   // 红色
  line(img, Point(300, 300), Point(758, 400), Scalar(0, 255, 255), 3);

  Point p(20, 20);//初始化点坐标为(20,20)
  circle(img, p, 1, Scalar(0, 255, 0), -1);  // 画半径为1的圆(画点）

  Point p4;
  p4.x = 300;
  p4.y = 300;
  circle(img, p4, 100, Scalar(120, 120, 120), -1);

  int thickness = 3;
  int lineType = 8;
  double angle = 30;  //椭圆旋转角度
  ellipse(img, Point(100, 100), Size(90, 60), angle, 0, 360, Scalar(255, 255, 0), thickness, lineType);

  // 画矩形
  Rect r(250, 250, 120, 200);
  rectangle(img, r, Scalar(0, 255, 255), 3);

  imshow("画板", img);
  waitKey();
  return 0;
}
```