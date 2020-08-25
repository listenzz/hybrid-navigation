import React, { useEffect, useCallback } from 'react'
import { View, Text, StyleSheet, TouchableHighlight } from 'react-native'
import withBottomModal from './withBottomModal'
import {
  RESULT_OK,
  Navigator,
  useVisibleEffect,
  InjectedProps,
} from 'react-native-navigation-hybrid'

function ReactModal({ navigator, sceneId }: InjectedProps) {
  useEffect(() => {
    navigator.setResult(RESULT_OK, {
      text: 'Are you male or female?',
      backId: sceneId,
    })
  }, [navigator, sceneId])

  const visibleCallback = useCallback(() => {
    console.info(`Page ReactModal is visible [${sceneId}]`)
    return () => {
      console.info(`Page ReactModal is gone [${sceneId}]`)
    }
  }, [sceneId])

  useVisibleEffect(sceneId, visibleCallback)

  async function hideModal(gender?: string) {
    if (gender) {
      navigator.setResult(RESULT_OK, {
        text: gender,
        backId: sceneId,
      })
    }
    await navigator.hideModal()
    const current = await Navigator.currentRoute()
    console.log(current)
  }

  function handleCancel() {
    hideModal()
  }

  const actionSheets = [
    {
      text: 'Male',
      onPress: () => {
        hideModal('Male')
      },
    },
    {
      text: 'Female',
      onPress: () => {
        hideModal('Female')
      },
    },
  ]

  const renderItem = (text: string, onPress: () => void) => {
    return (
      <TouchableHighlight onPress={onPress} underlayColor={'#212121'}>
        <View style={styles.item}>
          <Text style={styles.itemText}>{text}</Text>
        </View>
      </TouchableHighlight>
    )
  }

  return (
    <View style={styles.container}>
      {actionSheets.map(({ text, onPress }, index) => {
        const isLast = index === actionSheets.length - 1
        return (
          <View key={text} style={!isLast && styles.divider}>
            {renderItem(text, onPress)}
          </View>
        )
      })}
      <View style={styles.itemCancel}>{renderItem('Cancel', handleCancel)}</View>
    </View>
  )
}

export default withBottomModal({ safeAreaColor: '#F3F3F3' })(ReactModal)

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#F3F3F3',
  },
  item: {
    height: 50,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
  },
  divider: {
    marginBottom: 1,
  },
  itemCancel: {
    marginTop: 10,
    backgroundColor: '#FFFFFF',
  },
  itemText: {
    fontSize: 18,
    color: '#212121',
  },
})
