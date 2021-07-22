## 如何监听页面显示或隐藏

使用 `useVisibleEffect`

```tsx
import React, { useCallback } from 'react'
import { useVisibleEffect } from 'hybrid-navigation'

useVisibleEffect(
  useCallback(() => {
    Alert.alert('Lifecycle Alert!', 'componentDidAppear.')
    return () => Alert.alert('Lifecycle Alert!', 'componentDidDisappear.')
  }, []),
)
```

如果需要获取页面可见状态，使用 `useVisible` 或者 `useVisibility`。
