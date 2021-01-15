Hooks

### 如何监听页面显示或隐藏

```javascript
import React, { useCallback } from 'react'
import { useVisibleEffect } from 'hybrid-navigation'

function Lifecycle(props) {
  const visibleCallback = useCallback(() => {
    console.info(`Page is visible`)
    return () => {
      console.info(`Page is gone`)
    }
  }, [])

  useVisibleEffect(sceneId, visibleCallback)
}
```

### 如何统一处理页面返回的结果

```javascript
import { useResult } from 'hybrid-navigation'

useResult(sceneId, (requestCode, resultCode, data) => {
  console.info(`requestCode: ${requestCode}`, `resultCode: ${resultCode}`, data)
})
```
