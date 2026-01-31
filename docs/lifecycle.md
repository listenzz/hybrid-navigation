# 可见性监听

## 如何监听页面显示或隐藏

使用 `useVisibleEffect`

```tsx
import React, { useCallback } from 'react';
import { useVisibleEffect } from 'hybrid-navigation';

useVisibleEffect(() => {
  Alert.alert('Lifecycle Alert!', 'componentDidAppear.');
  return () => Alert.alert('Lifecycle Alert!', 'componentDidDisappear.');
});
```
