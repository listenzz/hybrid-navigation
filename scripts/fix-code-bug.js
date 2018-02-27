const fs = require('fs-extra');

const vectorIconsBuildGradle = './node_modules/react-native-vector-icons/android/build.gradle';

const gradles = [vectorIconsBuildGradle];

gradles.forEach(gradle => {
  fs.readFile(gradle, 'utf8', function(err, data) {
    console.log('read gradle error:' + err);
    let str = data.replace(/^(\s+compileSdkVersion).*$/gm, '$1 rootProject.ext.compileSdkVersion');
    str = str.replace(/^(\s+buildToolsVersion).*$/gm, '$1 rootProject.ext.buildToolsVersion');
    str = str.replace(/^(\s+targetSdkVersion).*$/gm, '$1 rootProject.ext.targetSdkVersion');
    fs.outputFile(gradle, str);
  });
});
