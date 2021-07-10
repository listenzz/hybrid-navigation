## 如何监听页面显示或隐藏

使用 `useVisible`

```tsx
import React, { useCallback } from 'react'
import { useVisible } from 'hybrid-navigation'

const visible = useVisible(sceneId)

useEffect(() => {
  if (!visible) {
    return
  }

  Alert.alert('Lifecycle Alert!', 'componentDidAppear.')
  return () => Alert.alert('Lifecycle Alert!', 'componentDidDisappear.')
}, [visible])
```

如果需要精细控制，也可以直接使用 `useVisibility`，它有三个状态值。
