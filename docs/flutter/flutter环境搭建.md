1.安装vs code和flutter插件
```
(1)下载并且安装vs code
https://code.visualstudio.com/Download
(2)在vs中安装flutter插件（安装完flutter插件后dart插件会自动安装）
点击左边菜单栏的Extensions按钮->搜索flutter
```
---
2.下载flutter sdk
```
官方文档：https://flutter.dev/docs/get-started/install/windows
(1)https://storage.googleapis.com/flutter_infra/releases/stable/windows/flutter_windows_v1.12.13+hotfix.5-stable.zip
(2)解压到D:\flutter，并设置系统环境变量：D:\flutter\bin
(3)检测环境：运行flutter doctor
提示：Unable to locate Android SDK
感叹号的都不是致命问题 最主要就是那个安卓工具链了 这就需要我们安装Android SDK了
```
---
3.下载安装Android SDK
```
(1)因为我们不需要Android Studio，所以可以下载下面的基本Android命令行工具
https://developer.android.google.cn/studio#command-tools
(2)解压到D:\android_sdk
(3)进入tools\bin 找到sdkmanager.bat 我们按住shift键+右键这个目录的空白处 点击在此处打开powershell，输入命令： .\sdkmanager.bat --list
错误信息1：ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH
解决方法：安装jdk
错误信息2：Exception in thread "main" java.lang.NoClassDefFoundError: javax/xml/bind/annotation/XmlSchema
解决方法：卸载jdk-13.0.1，降低jdk版本到8，该版本为长期稳定版本(由于JDK9提出的模块化的概念，导致jjava.ee模块不在以后的版本里默认提供)
下载地址：https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
警告信息3：Warning: File C:\Users\Administrator\.android\repositories.cfg could not be loaded.
解决方法：创建此文件
```
---
4.安装jdk，并配置JAVA_HOME系统环境变量
```
(1)下载地址：https://www.oracle.com/technetwork/java/javase/downloads/index.html
(2)配置系统环境变量：D:\Program Files\Java\jdk-13.0.1
```
---
5.安装platform-tools、emulator、platforms;android-29、build-tools;28.0.3
```
(1)输入sdk(点击tab补全)，空格然后输入"plaform-tools"			//平台工具集
(2)输入sdk(点击tab补全)，空格然后输入"emulator" 				//模拟器
(3)输入sdk(点击tab补全)，空格然后输入"platforms;android-29"  //哪个apis，对应构建工具
(4)输入sdk(点击tab补全)，空格然后输入"build-tools;29.0.2"    //平台构建工具
(5)输入sdk(点击tab补全)，空格然后输入"system-images;android-29;google_apis_playstore;x86"    //如果你用模拟器就需要一个系统镜像
(6)输入sdk(点击tab补全)，空格然后输入"extras;intel;Hardware_Accelerated_Execution_Manager" //PC硬件加速相关
(7)输入sdk(点击tab补全)，空格然后输入"patcher;v4" //补丁包
```
---
6.配置Android sdk系统环境变量
```
(1)添加系统环境变量：ANDROID_HOME=D:\android_sdk
(2)编辑path环境变量，输入如下值：
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\tools
(3)检查配置是否成功，在cmd中输入命令：adb
```
---
7.运行flutter项目启动模拟器失败
```
(1)Please ensure Windows Hypervisor Platform (WHPX) is properly installed and usable.CPU acceleration status: HAXM is not installed on this machine More info on configuring VM acceleration on Windows
解决方法：确保安装了最新的BIOS。应在BIOS中打开VT-x和VT-d；然后下载并安装haxm：https://github.com/intel/haxm
```
参考文档：https://blog.csdn.net/SVNzK/article/details/84314226
