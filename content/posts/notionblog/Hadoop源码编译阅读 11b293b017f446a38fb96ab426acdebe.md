---
title: "Hadoop源码编译阅读"
date: 2023-01-26
draft: false
tags: ["归档","Hadoop"]
---

mvn test -Dtest=TestLongLong

在跑测试的时候，出现了如下问题

[**ERROR**] Failed to execute goal org.apache.maven.plugins:maven-antrun-plugin:1.7:run **(common-test-bats-driver)** on project hadoop-common: **An Ant BuildException has occured: exec returned: 1**

[**ERROR**] **around Ant part ...<exec failonerror="true" dir="src/test/scripts" executable="bash">... @ 4:69 in /home/chuhuilong/hadoop/hadoop-common-project/hadoop-common/target/antrun/build-main.xml**

根据错误提示，是hadoop-common这个模块中的antrun插件有问题，去该模块的pom中查看，

![Untitled](/img/Hadoop%E6%BA%90%E7%A0%81%E7%BC%96%E8%AF%91%E9%98%85%E8%AF%BB%2011b293b017f446a38fb96ab426acdebe/Untitled.png)

是执行这个execution的时候出错了。

拿着common test bats driver关键词去hadoop官方的社区里搜索

[https://issues.apache.org/jira/browse/HADOOP-14618](https://issues.apache.org/jira/browse/HADOOP-14618) 这个问题和我的出错一样，hadoop版本是3.0.0也很接近，只有一条评论说是running the build as a non-root user，以非root用户权限执行之前在网上看别人调试hadoop2.0版本的时候强调过，但是我是用的官方docker直接调试的，这些用户权限应该都是调好了的吧。并且这个issue中有执行的脚本出错的具体信息，我这边是没有的。

不过和我这个信息一样的就只有这个issue了，那我看看我执行mvn命令的用户权限是什么

还是没看出什么

再沉思分析一下，这个插件是在做脚本执行的测试，说明是有脚本执行失败了，那我找出来是哪个脚本之心失败了应该就可以进一步分析

看到插件里面，是执行了src/test/scripts下的run-bats.sh

![Untitled](/img/Hadoop%E6%BA%90%E7%A0%81%E7%BC%96%E8%AF%91%E9%98%85%E8%AF%BB%2011b293b017f446a38fb96ab426acdebe/Untitled%201.png)

可以看到这个脚本就是把scripts下的脚本都跑一遍

再看看我的日志，说明这个脚本跑起来了了，有脚本没跑起来，那就按照顺序看看是到哪个没跑起来

![Untitled](/img/Hadoop%E6%BA%90%E7%A0%81%E7%BC%96%E8%AF%91%E9%98%85%E8%AF%BB%2011b293b017f446a38fb96ab426acdebe/Untitled%202.png)

官方issue里是hadoop_mkdir.bats这个脚本没跑通，我这里这个脚本跑通了

我最后一个start-build-env.bats的脚本已经执行了也没报错，为什么还是没通过呢？

![Untitled](/img/Hadoop%E6%BA%90%E7%A0%81%E7%BC%96%E8%AF%91%E9%98%85%E8%AF%BB%2011b293b017f446a38fb96ab426acdebe/Untitled%203.png)

是不是全部跑完然后中间有不ok的就算报错，于是我回头再看了一遍日志

原来hadoop_java_setup.bats这个脚本中有not ok的

![Untitled](/img/Hadoop%E6%BA%90%E7%A0%81%E7%BC%96%E8%AF%91%E9%98%85%E8%AF%BB%2011b293b017f446a38fb96ab426acdebe/Untitled%204.png)

看看这个脚本

![Untitled](/img/Hadoop%E6%BA%90%E7%A0%81%E7%BC%96%E8%AF%91%E9%98%85%E8%AF%BB%2011b293b017f446a38fb96ab426acdebe/Untitled%205.png)

原来这个脚本里有四个测试，这时我也才搞懂日志中1..4是代表测试的数目

第三个测试出了问题

这一下问题更精确了，带着hadoop_java_setup这个关键字再去hadoop社区看一下

但是这个关键字太宽泛了，一大堆有关的问题

这个测试猜测是要没有执行权限的时候不执行，但是不知道为什么这里的chmod a-x好像没有起作用，我把-eq 1 改成-eq 0，也就是和第四个对比测试一样就能暂时通过了，不过这应该是个问题。

想要执行单元测试

遇到了这个问题

**Unable to load Atom 'execute_script' from file ':/ghostdriver/./third_party/webdriver-atoms/execute_script.js'**

看样子是浏览器的问题，官方的docker应该只是用来编译的最小依赖

[Selenium](http://about.uuspider.com/2017/12/17/selenium.html)

装了个selenium，并没有用

可能是phantomjs有问题

看一下版本

phantomjs is already the newest version (2.1.1+dfsg-2ubuntu1).

我的usr/bin目录下有phantomjs这个二进制文件，可能是版本不对？

[Unable to load Atom ''find_element"](https://stackoverflow.com/questions/36770303/unable-to-load-atom-find-element)

根据这个问题，用apt下载的phantomjs好像有问题，需要手动下载

curl -L -s -S [https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2](https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2) -o phantomjs-2.1.1-linux-x86_64.tar.bz2

tar -xf phantomjs-2.1.1-linux-x86_64.tar.bz2

sudo cp phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/bin/

**The jasmine-maven-plugin encountered an exception:**

[**ERROR**] **org.openqa.selenium.remote.UnreachableBrowserException: Could not start a new session. Possible causes are invalid address of the remote server or browser start-up failure.**

这个错误应该就是网络问题

**Caused by: org.openqa.selenium.WebDriverException: Timed out waiting for driver server to start.**

不过好在是容器，销毁了重新创建一个就好了

现在了解了，selenium是做浏览器测试的工具，也就是hadoop用这个工具来测试它的yarnUI界面，

![Untitled](/img/Hadoop%E6%BA%90%E7%A0%81%E7%BC%96%E8%AF%91%E9%98%85%E8%AF%BB%2011b293b017f446a38fb96ab426acdebe/Untitled%206.png)

仔细看看错误日志，有很多有趣的信息，一个是报错，还有就是生成了log文件

看这个样子和我之前猜测的网络问题应该无关，应该就是启动问题

Feb 13, 2023 1:54:43 PM org.openqa.selenium.phantomjs.PhantomJSDriverService <init>
INFO: environment: {}
qemu-x86_64: Could not open '/lib64/ld-linux-x86-64.so.2': No such file or directory
Feb 13, 2023 1:55:03 PM org.openqa.selenium.os.UnixProcess checkForError
SEVERE: org.apache.commons.exec.ExecuteException: Process exited with an error: 255 (Exit value: 255)

那去搜搜这个问题

[qemu-x86_64: Could not open '/lib64/ld-linux-x86-64.so.2': No such file or directory](https://stackoverflow.com/questions/71040681/qemu-x86-64-could-not-open-lib64-ld-linux-x86-64-so-2-no-such-file-or-direc)

根据这个问题开来，这好像是mac m1芯片的问题