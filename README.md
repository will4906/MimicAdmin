# MimicAdmin

一个基于mybatis查询Medical Information Mart for Intensive Care的sql管理工具

### 目录解释：

* doc/index.html 为java api函数说明文档，双击使用浏览器查看

* src/main/java/com/willshuhua/Main.java 为整个工程的启动文件，可在此处配置表名称

* src/main/java/com/willshuhua/demo/ 存放demo文件，目前做了一套ards的执行代码，理论上在java、python和数据库环境完备的情况下可以完全复原数据，部分参数由于计算比较复杂需单独执行python文件

* res/python 存放几个特殊变量的python执行文件

* res/result 存放历次生成的结果

* res/sql存放一些备份sql和源代码

### 结果文件

均以https://github.com/will4906/MimicAdmin/tree/master/res/result 为准。文件夹下的csv文件可直接在网页显示。如需修改请下载后修改。