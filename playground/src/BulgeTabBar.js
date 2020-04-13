import React from 'react'
import {
  Text,
  View,
  Image,
  TouchableOpacity,
  StyleSheet,
  PixelRatio,
  Platform,
  Dimensions,
} from 'react-native'
import TextBadge from './Badge'

export default function BulgeTabBar({
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
      console.log(resultCode, data)
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

  return (
    <View style={styles.container}>
      <View style={styles.tabBar}>
        <Tab
          onTabClick={() => handleTabClick(0)}
          {...tabs[0]}
          selected={selectedIndex === 0}
          {...style}
        />
        <Tab unselectedItemColor="rgb(255,197,99)" title="发布" />
        <Tab
          onTabClick={() => handleTabClick(1)}
          {...tabs[1]}
          selected={selectedIndex === 1}
          {...style}
        />
      </View>
      <TouchableOpacity onPress={() => handleTabClick(-1)} activeOpacity={0.8} style={styles.bulge}>
        <Image source={require('./images/tabbar_add_yellow.png')} fadeDuration={0} />
      </TouchableOpacity>
    </View>
  )
}

function Tab({
  onTabClick,
  icon,
  title,
  selected,
  unselectedItemColor,
  itemColor,
  badgeText,
  textBadgeStyle,
  dot,
  dotBadgeStyle,
}) {
  return (
    <TouchableOpacity onPress={onTabClick} activeOpacity={0.8} style={styles.tab}>
      {icon ? (
        <Image
          source={{
            uri: icon,
            width: 24,
            height: 24,
            scale: PixelRatio.get(),
          }}
          style={{ tintColor: selected ? itemColor : unselectedItemColor }}
          resizeMode="center"
          fadeDuration={0}
        />
      ) : (
        <View style={{ width: 24, height: 24 }} />
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

function DotBadge(props) {
  return <View style={[styles.dotBadge, props.style]} />
}

const styles = StyleSheet.create({
  container: {
    height: Platform.OS === 'android' ? 78 : 72,
    width: Dimensions.get('window').width,
    justifyContent: 'flex-start',
    alignItems: 'center',
  },
  bulge: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  tabBar: {
    height: Platform.OS === 'android' ? 56 : 48,
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'stretch',
  },
  tab: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
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
