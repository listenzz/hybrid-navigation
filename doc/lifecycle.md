Hooks

### 如何监听页面显示或隐藏

```javascript
import React, { useEffect } from 'react'
import { useVisibility } from 'react-native-navigation-hybrid'

function Lifecycle(props) {
  const visibility = useVisibility(sceneId)

  useEffect(() => {
    if (visibility === 'visible') {
      console.info(`Page is visible`)
    } else if (visibility === 'gone') {
      console.info(`Page is gone`)
    }
  },[visibility])
```

### 如何统一处理页面返回的结果

```javascript
import { useResult } from 'react-native-navigation-hybrid'

useResult(sceneId, (requestCode, resultCode, data) => {
  console.info(`requestCode: ${requestCode}`, `resultCode: ${resultCode}`, data)
})
```