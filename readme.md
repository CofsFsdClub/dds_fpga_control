# 工程概况
    * 主控 高云FPGA GW5A DDS时序控制主频500M，其它工作频率50M
    * DDS芯片 AD9910
    * 产生信号类型 脉冲啁啾信号


## 20240412
    * 第一次提交：
        这一版本的代码功能：
        1、DDS扫频时序控制
        2、串口解码

## 20240418
    * 第二次提交：
        新增代码功能：
        1、串口解码转SPI代码发送，需要注意FPGA代码固化了7条指令，初此之外发送的串口指令不可被解析
        2、更新串口指令格式为:AA|55|num|addr|cmd|CE
        3、优化串口，SPI即DDS扫频控制时序