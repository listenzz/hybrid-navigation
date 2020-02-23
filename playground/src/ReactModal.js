import React from 'react'
import { View, Text, StyleSheet, TouchableHighlight } from 'react-native'
import withBottomModal from './withBottomModal'
import { RESULT_OK, Navigator } from 'react-native-navigation-hybrid'

class ReactModal extends React.Component {
  constructor(props) {
    super(props)
    this.handleCancel = this.handleCancel.bind(this)
    this.hideModal = this.hideModal.bind(this)
  }

  actionSheets = [
    {
      text: 'Male',
      onPress: () => {
        this.hideModal('Male')
      },
    },
    {
      text: 'Female',
      onPress: () => {
        this.hideModal('Female')
      },
    },
  ]

  componentDidMount() {
    this.props.navigator.setResult(RESULT_OK, {
      text: 'Are you male or female?',
      backId: this.props.sceneId,
    })
    console.info('modal componentDidMount')
  }

  componentDidAppear() {
    console.info('modal componentDidAppear')
  }

  componentDidDisappear() {
    console.info('modal componentDidDisappear')
  }

  componentWillUnmount() {
    console.info('modal componentWillUnmount')
  }

  async hideModal(gender) {
    if (gender) {
      this.props.navigator.setResult(RESULT_OK, {
        text: gender,
        backId: this.props.sceneId,
      })
    }
    await this.props.navigator.hideModal()
    const current = await Navigator.currentRoute()
    console.log(current)
  }

  handleCancel() {
    this.hideModal()
  }

  renderItem = (text, onPress) => {
    return (
      <TouchableHighlight onPress={onPress} underlayColor={'#212121'}>
        <View style={styles.item}>
          <Text style={styles.itemText}>{text}</Text>
        </View>
      </TouchableHighlight>
    )
  }

  render() {
    return (
      <View style={styles.container}>
        {this.actionSheets.map(({ text, onPress }, index) => {
          const isLast = index === this.actionSheets.length - 1
          return (
            <View key={text} style={!isLast && styles.divider}>
              {this.renderItem(text, onPress)}
            </View>
          )
        })}
        <View style={styles.itemCancel}>{this.renderItem('Cancel', this.handleCancel)}</View>
      </View>
    )
  }
}

export default withBottomModal()(ReactModal)

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
