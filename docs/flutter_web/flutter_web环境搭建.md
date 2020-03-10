1.安装vs code和flutter插件(Flutter v3.0以上扩展包)
```
(1)下载并且安装vs code：https://code.visualstudio.com/Download
(2)在vs中安装flutter插件（安装完flutter插件后dart插件会自动安装），点击左边菜单栏的Extensions按钮->搜索flutter
(3)说明：
- Flutter插件是用来支持Flutter开发工作流 (运行、调试、热重载等)
- Dart插件提供代码分析 (输入代码时进行验证、代码补全等)
```

2.下载flutter sdk
```
官方文档：https://flutter.dev/docs/get-started/install/windows
(1)https://storage.googleapis.com/flutter_infra/releases/stable/windows/flutter_windows_v1.12.13+hotfix.5-stable.zip
(2)解压到D:\flutter，并设置系统环境变量：D:\flutter\bin，以便于你能在命令行中使用flutter
(3)检测环境：运行flutter version
(4)说明：
由于在国内安装Flutter相关的依赖可能会受到限制，Flutter官方为中国开发者搭建了临时镜像，大家可以将如下环境变量加入到用户环境变量中：
PUB_HOSTED_URL：https://pub.flutter-io.cn
FLUTTER_STORAGE_BASE_URL： https://storage.flutter-io.cn
```

3.下载Dart与Pub
```
(1)Dart获取地址：https://www.gekorm.com/dart-windows
(2)双击安装到D:\Program Files\Dart，并将D:\Program Files\Dart\dart-sdk\bin设置到系统环境变量Path中(默认安装完后会自动添加环境变量)，以便于可以在命令行中使用dart与pub
(3)Pub是Dart的包管理工具，类似npm，捆绑安装
(4)检测环境：
- 运行dart --version
- 运行pub --version
```

4.安装flutter_web的编译工具webdev(webdev是一个类似于Koa的web服务器)
```
(1)安装
//环境变量只配置了flutter sdk而没有配置dart sdk(flutter指令里面有配置dart_sdk路径)
flutter pub global activate webdev
//环境变量已经配置了dart sdk
pub global activate webdev
(2)设置系统环境变量到Path：D:\flutter\.pub-cache\bin
```

5.创建flutter web项目
```
(1)因为flutter web还在测试阶段，默认没有选项Flutter: New Web Project，需要执行以下命令：
flutter channel beta
flutter upgrade
flutter config --enable-web
```
(2)命令行创建web项目，需要安装工具stagehand
安装：$ flutter pub global activate stagehand
查看帮助：$ flutter pub global run stagehand
Available generators:
  console-full   - A command-line application sample.
  package-simple - A starting point for Dart libraries or applications.
  server-shelf   - A web server built using the shelf package.
  web-angular    - A web app with material design components.
  web-simple     - A web app that uses only core Dart libraries.
  web-stagexl    - A starting point for 2D animation and games.

创建项目目录，并cd到项目目录
创建一个web项目：$ flutter pub global run stagehand web-simple
配置项目：$ flutter pub get
运行项目：$ flutter pub global run webdev serve，错误提示：No active package webdev. pub finished with exit code 65
解决方法：设置系统环境变量到Path：D:\flutter\.pub-cache\bin，因为安装的webdev在这个目录下
