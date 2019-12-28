1.flutter 卡在Running Gradle task 'assembleDebug'...，因为Gradle的Maven仓库在国外, 可以使用阿里云的镜像地址。
(1)修改项目中`android/build.gradle`文件
```
repositories {
    //修改的地方
    //google()
    //jcenter()
	maven { url 'https://maven.aliyun.com/repository/google' }
    maven { url 'https://maven.aliyun.com/repository/jcenter' }
    maven { url 'http://maven.aliyun.com/nexus/content/groups/public' }
}

allprojects {
    repositories {
    	//修改的地方
        // google()
        // jcenter()
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/jcenter' }
        maven { url 'http://maven.aliyun.com/nexus/content/groups/public' }
    }
}
```
(2)修改Flutter的配置文件, 该文件在`Flutter安装目录/packages/flutter_tools/gradle/flutter.gradle`
```
repositories {
    //修改的地方
    //google()
    //jcenter()
    maven { url 'https://maven.aliyun.com/repository/google' }
    maven { url 'https://maven.aliyun.com/repository/jcenter' }
    maven { url 'http://maven.aliyun.com/nexus/content/groups/public' }
}
```

_ _ _

1212
