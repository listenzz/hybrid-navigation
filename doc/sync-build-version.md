### 同步构建版本

Navigation Hybrid 使用的构建版本是 28.0.1 ，你的项目可能使用了更高的版本，你也可能使用了 [react-native-vector-icons](https://github.com/oblador/react-native-vector-icons) 这样的库，它的构建版本是 26.0.1 ，我们需要用脚本把这些库的构建版本统一起来，否则编译项目时可能会出错。

回到 RN 项目的根目录，创建一个叫 scripts 的文件夹，在里面创建一个叫 sync-build-version.js 的文件

```javascript
const fs = require('fs-extra');

// 找到 NavigatonHybrid 的 build.gradle 文件
const navigationHybrid = './node_modules/react-native-navigation-hybrid/android/build.gradle';

// 其它使用了原生源码的库，例如：
// const codePush = './node_modules/react-native-code-push/android/app/build.gradle'
// const vectorIcons = './node_modules/react-native-vector-icons/android/build.gradle'

const gradles = [
  navigationHybrid,
  // codePush,
  // vectorIcons,
];

gradles.forEach(gradle => {
  fs.readFile(gradle, 'utf8', function(err, data) {
    if (err) {
      console.warn(err);
      return;
    }

    let str = data.replace(/^(\s+compileSdkVersion).*$/gm, '$1 rootProject.ext.compileSdkVersion');
    str = str.replace(/^(\s+buildToolsVersion).*$/gm, '$1 rootProject.ext.buildToolsVersion');
    str = str.replace(/^(\s+targetSdkVersion).*$/gm, '$1 rootProject.ext.targetSdkVersion');
    str = str.replace(
      /["'](com\.android\.support:appcompat-v7:).*["']/gm,
      '"$1$rootProject.ext.supportLibVersion"'
    );
    str = str.replace(
      /["'](com\.android\.support:support-v4:).*["']/gm,
      '"$1$rootProject.ext.supportLibVersion"'
    );
    str = str.replace(
      /["'](com\.android\.support:design:).*["']/gm,
      '"$1$rootProject.ext.supportLibVersion"'
    );
    str = str.replace(/\scompile\s/gm, ' implementation ');
    str = str.replace(
      /classpath\s+'com\.android\.tools\.build:gradle:.+['""]/gm,
      `classpath 'com.android.tools.build:gradle:3.1.4'`
    );
    if (str.search('google\\(\\)') === -1) {
      str = str.replace(/(.+)jcenter\(\)/gm, '$1jcenter()\n$1google()');
    }
    fs.outputFile(gradle, str);
  });
});
```

现在，让我们激活这个脚本。打开 package.json 文件，作如下修改

```diff
"scripts": {
"start": "react-native start",
+   "sbv": "node scripts/sync-build-version.js",
+   "postinstall": "npm run sbv"
}
```

执行一次 `npm install` 或 `yarn install`
