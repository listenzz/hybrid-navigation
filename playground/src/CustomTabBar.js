import React, { useEffect } from 'react'
import { Text, View, TouchableOpacity, StyleSheet, Dimensions, Platform, Image } from 'react-native'
import TextBadge from './Badge'
import FastImage from 'react-native-fast-image'

const PlatformImage = Platform.OS === 'android' ? FastImage : Image

export default function CustomTabBar({
  sceneId,
  navigator,
  itemColor,
  unselectedItemColor,
  badgeColor,
  tabs,
  selectedIndex,
}) {
  async function handleTabClick(index) {
    if (index === -1) {
      const [resultCode, data] = await navigator.present('Result')
      console.log(`CustomTabBar resultCode: ${resultCode} data:`, data)
    } else {
      navigator.switchTab(index)
    }
  }

  const style = {
    textBadgeStyle: { backgroundColor: badgeColor },
    dotBadgeStyle: { backgroundColor: badgeColor },
    unselectedItemColor,
    itemColor,
  }

  useEffect(() => {
    console.log(`CustomTabBar sceneId:${sceneId}`)
  }, [sceneId])

  return (
    <View style={styles.tabBar}>
      <Tab
        onTabClick={() => handleTabClick(0)}
        {...tabs[0]}
        selected={selectedIndex === 0}
        {...style}
      />
      <Add onTabClick={() => handleTabClick(-1)} />
      <Tab
        onTabClick={() => handleTabClick(1)}
        {...tabs[1]}
        selected={selectedIndex === 1}
        {...style}
      />
    </View>
  )
}

function Add({ onTabClick }) {
  return (
    <TouchableOpacity onPress={onTabClick} activeOpacity={0.8} style={styles.tab}>
      <FastImage source={require('./images/tabbar_add_blue.png')} style={styles.centerIcon} />
    </TouchableOpacity>
  )
}

function Tab({
  onTabClick,
  icon,
  title,
  selected,
  itemColor,
  unselectedItemColor,
  badgeText,
  textBadgeStyle,
  dot,
  dotBadgeStyle,
}) {
  return (
    <TouchableOpacity onPress={onTabClick} activeOpacity={0.8} style={styles.tab}>
      {icon ? (
        <PlatformImage
          source={{
            uri: icon,
            width: 24,
            height: 24,
          }}
          style={[styles.icon, { tintColor: selected ? itemColor : unselectedItemColor }]}
          resizeMode="contain"
          tintColor={selected ? itemColor : unselectedItemColor}
        />
      ) : (
        <View style={styles.icon} />
      )}
      <Text
        style={
          selected
            ? [styles.buttonTextSelected, { color: itemColor }]
            : [styles.buttonText, { color: unselectedItemColor }]
        }>
        {title}
      </Text>
      {badgeText && <TextBadge style={[styles.textBadge, textBadgeStyle]}>{badgeText}</TextBadge>}
      {dot && <DotBadge style={dotBadgeStyle} />}
    </TouchableOpacity>
  )
}

function DotBadge({ style }) {
  return <View style={[styles.dotBadge, style]} />
}

const styles = StyleSheet.create({
  tabBar: {
    height: Platform.OS === 'android' ? 56 : 48,
    width: Dimensions.get('window').width,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'stretch',
  },
  tab: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  icon: {
    width: 24,
    height: 24,
  },
  centerIcon: {
    width: 40,
    height: 40,
  },
  buttonText: {
    backgroundColor: 'transparent',
    fontSize: 12,
  },
  buttonTextSelected: {
    backgroundColor: 'transparent',
    fontSize: 12,
  },
  textBadge: {
    position: 'absolute',
    bottom: '50%',
    left: '50%',
    marginBottom: 6,
    marginLeft: 6,
  },
  dotBadge: {
    position: 'absolute',
    bottom: '50%',
    left: '50%',
    marginBottom: 10,
    marginLeft: 10,
    height: 12,
    width: 12,
    borderWidth: 1,
    borderColor: '#fefefe',
    borderRadius: 14 / 2,
    backgroundColor: 'rgb(0, 122, 255)',
  },
})
