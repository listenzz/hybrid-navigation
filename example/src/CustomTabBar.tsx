import React, { useEffect } from 'react'
import {
  Text,
  View,
  TouchableOpacity,
  StyleSheet,
  Dimensions,
  Platform,
  Image,
  ViewStyle,
  ViewProps,
} from 'react-native'
import TextBadge from './Badge'
import FastImage from 'react-native-fast-image'
import { NavigationProps, Color } from 'hybrid-navigation'

const PlatformImage = Platform.OS === 'android' ? FastImage : Image

interface Props extends NavigationProps {
  itemColor: Color
  unselectedItemColor: Color
  badgeColor: Color
  tabs: any[]
  selectedIndex: number
}

export default function CustomTabBar({
  sceneId,
  navigator,
  itemColor,
  unselectedItemColor,
  badgeColor,
  tabs,
  selectedIndex,
}: Props) {
  async function handleTabClick(index: number) {
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

function Add({ onTabClick }: Partial<TabProps>) {
  return (
    <TouchableOpacity onPress={onTabClick} activeOpacity={0.8} style={styles.tab}>
      <FastImage source={require('./images/tabbar_add_blue.png')} style={styles.centerIcon} />
    </TouchableOpacity>
  )
}

interface TabProps {
  onTabClick: () => void
  icon: string
  title: string
  selected: boolean
  unselectedItemColor: Color
  itemColor: Color
  badgeText?: string
  textBadgeStyle: ViewStyle
  dot?: boolean
  dotBadgeStyle: ViewStyle
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
}: TabProps) {
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
      {!!badgeText && <TextBadge style={[styles.textBadge, textBadgeStyle]}>{badgeText}</TextBadge>}
      {dot && <DotBadge style={dotBadgeStyle} />}
    </TouchableOpacity>
  )
}

function DotBadge({ style }: ViewProps) {
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
