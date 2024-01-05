# ANTLR学习日志

date: February 28, 2023
inList: No
inMenu: No
publish: Yes
tags: ANTLR, 归档
template: post

阅读的是作者自己写的**[The Definitive ANTLR 4 Reference](https://dl.icdst.org/pdfs/files3/a91ace57a8c4c8cdd9f1663e1051bf93.pdf)**

使用方式：

要装有jdk

```bash
cd /usr/local/lib # 找一个想安装的目录就行
curl -O https://www.antlr.org/download/antlr-4.0-complete.jar# 这里必须使用https的链接，https://github.com/antlr/antlr4/issues/2422
# 一个jar包就可以跑了，下面都是为了省事
export CLASSPATH=".:/usr/local/lib/antlr-4.0-complete.jar:$CLASSPATH"
alias antlr4='java -jar /usr/local/lib/antlr-4.0-complete.jar'
```

## helloword

```bash
grammar Hello;            // Define a grammar called Hello
r : 'hello' ID ;          // match keyword hello followed by an identifier
ID : [a-z]+ ;             // match lower-case identifiers
WS : [ \t\r\n]+ -> skip ; // skip spaces, tabs, newlines, \r (Windows)
```

```bash
antlr4 Hello.g4
javac *.java
```

使用antlr自带的测试工具TestBig

```bash
alias grun='java org.antlr.v4.runtime.misc.TestRig'
grun Hello r -tokens #start the TestRig on grammar Hello at rule r
hello parrt          #input for the recognizer that you type
#最后输入crtl-D来结束
```

结果

```bash
[@0,0:4='hello',<1>,1:0]
[@1,6:10='parrt',<2>,1:6]
[@2,12:11='<EOF>',<-1>,2:0]
```

@1表示这是第2个符号（从0开始计数），6:10表示这个元素的下标从6到10，<2>表示这个是我们定义的g4文件中第2个token（也就是ID），1:6表示在第一行下标6处

其它方式

```
-tokens prints out the token stream.
-tree prints out the parse tree in LISP form.
-gui displays the parse tree visually in a dialog box.
-ps file.ps generates a visual representation of the parse tree in PostScript and stores it in file.ps. The parse tree figures in this chapter were generated with -ps.
-encoding encodingname specifies the test rig input file encoding if the current locale would not read the input properly.
-trace prints the rule name and current token upon rule entry and exit.
-diagnostics turns on diagnostic messages during parsing. This generates mes-
sages only for unusual situations such as ambiguous input phrases.
-SLL uses a faster but slightly weaker parsing strategy.
```

ANTLR的包本身分两个部分，一个是tool工具，用来根据g4文件生成对应的java文件，还有一个是runtime库，是生成的java类会使用到的一些类。

tool类只是用来生成文件的，我是用idea插件来生成，项目中就只需要引入runtime的mvn依赖就行了

```
<dependency>
      <groupId>org.antlr</groupId>
      <artifactId>antlr4-runtime</artifactId>
      <version>4.9.3</version>
</dependency>
```