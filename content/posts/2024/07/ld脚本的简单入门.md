---
title: "Ld脚本的简单入门"
date: 2024-07-28T15:56:48+08:00
draft: false
---

```
SECTIONS
{
    . = 0x80000;     /* Kernel load address for AArch64 */
    .text : { 
        KEEP(*(.text.boot)) *(.text .text.* .gnu.linkonce.t*) 
    }
    .rodata : {
         *(.rodata .rodata.* .gnu.linkonce.r*) 
    }
    PROVIDE(_data = .);
    .data : { 
        *(.data .data.* .gnu.linkonce.d*) 
    }
    .bss (NOLOAD) : {
        . = ALIGN(16);
        __bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        __bss_end = .;
    }
    _end = .;

   /DISCARD/ : { *(.comment) *(.gnu*) *(.note*) *(.eh_frame*) }
}
__bss_size = (__bss_end - __bss_start)>>3;
```

每个链接脚本都需要有SECTIONS，每个SECTIONS里面可以定义多个secname，比如示例里的.text，.rodata，.data，.bss都是secname。ld脚本只要求secname是一个[标准的名字](https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_mono/ld.html#SEC9)就可以。链接的文件具体的secname都叫什么，是由目标文件格式限制的。比如想要链接出一个ELF, 那么就得满足[ELF的格式要求](https://wiki.osdev.org/ELF)。当然了，还可能有工具或者其他需求会对secname有要求，总之， secname的命名是由实际的需求决定的，不是ld的要求。

示例中的脚本，是用来链接一个在树莓派4B上运行的小型操作系统，树莓派4B使用的芯片是ARM Cortex-A72 MPCore Processor，因为没有特殊要求，所有只需要确保程序的第一行代码放在0x80000处就可以（芯片通电后对读取这个地址的代码）。

有一点需要注意，ld链接后的文件的[执行入口的定义](https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_3.html#SEC24)，是按照文档中来的，在示例中我们没有显示定义入口点，也没有定义start这个symbol, 如果执行链接时没有使用-e指定入口，那么会最终的入口是.text段的开头（如果.text都没有，那就使用0做入口地址了）。EntryPoint会被放在最终生成的可执行文件的头中，操作系统或者硬件的启动程序执行文件的时候回去头里面找EntryPoint。

示例中的链接脚本最终会用来链接出一个ELF文件，树莓派4B支持使用ELF文件启动操作系统，具体的启动软件是闭源的，那些软件是随着主板一起出厂的，只要知道既然说支持ELF，那就可以读取到我的ELF文件到内存中去。（而且这里应该是放到物理地址，假如硬件支持虚拟地址，也得等操作系统把页表准备好了，并且打开启动虚拟地址的开关才行）。
