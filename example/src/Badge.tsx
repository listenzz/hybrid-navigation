import React from 'react'
import { StyleSheet, Text } from 'react-native'
import { useLayout } from '@react-native-community/hooks'

export default function Badge(props: any) {
  const { onLayout, width, height } = useLayout()

  let style = {} as any
  if (width === 0 || height === 0) {
    style.opacity = 0
  } else {
    style.width = Math.max(height, width)
  }

  return (
    <Text
      {...props}
      numberOfLines={1}
      onLayout={onLayout}
      style={[styles.container, props.style, style]}>
      {props.children}
    </Text>
  )
}

let styles = StyleSheet.create({
  container: {
    fontSize: 10,
    color: '#fff',
    paddingLeft: 4,
    paddingRight: 4,
    backgroundColor: 'rgb(0, 122, 255)',
    lineHeight: 15,
    textAlign: 'center',
    borderWidth: 1,
    borderColor: '#fefefe',
    borderRadius: 17 / 2,
    overflow: 'hidden',
  },
})
