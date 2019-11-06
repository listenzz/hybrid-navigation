import React, { Component } from 'react'
import { Text, View, TouchableOpacity, ScrollView, Alert, Image } from 'react-native'
import { LayoutFittingExpanded } from 'react-native-navigation-hybrid'
import styles from './Styles'

function CustomTitleView(props) {
  let { params } = props.navigator.state
  return (
    <View
      style={{
        flex: 1,
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
      }}>
      <Text style={styles.welcome}>--Custom Title--</Text>
      <TouchableOpacity onPress={params.onFackbookButtonClick}>
        <Image
          style={{ width: 24, height: 24 }}
          source={{ uri: 'https://facebook.github.io/react-native/docs/assets/favicon.png' }}
        />
      </TouchableOpacity>
    </View>
  )
}

export { CustomTitleView }

export default class TopBarTitleView extends Component {
  static navigationItem = {
    backButtonHidden: true,
    titleItem: {
      moduleName: 'CustomTitleView', // registered component name
      layoutFitting: LayoutFittingExpanded, // `LayoutFittingExpanded` or `LayoutFittingCompressed`, default is `LayoutFittingExpanded`
    },
  }

  constructor(props) {
    super(props)
    this.topBarTitleView = this.topBarTitleView.bind(this)
    this.props.navigator.setParams({
      onFackbookButtonClick: this.onFackbookButtonClick.bind(this),
    })
  }

  onFackbookButtonClick() {
    Alert.alert('Hello!', 'React button is clicked.', [{ text: 'OK', onPress: () => console.log('OK Pressed') }], {
      cancelable: false,
    })
  }

  topBarTitleView() {
    this.props.navigator.push('TopBarTitleView')
  }

  render() {
    return (
      <ScrollView
        contentInsetAdjustmentBehavior="never"
        automaticallyAdjustContentInsets={false}
        contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
        <View style={styles.container}>
          <Text style={styles.welcome}> Custom title bar </Text>

          <TouchableOpacity onPress={this.topBarTitleView} activeOpacity={0.2} style={styles.button}>
            <Text style={styles.buttonText}>TopBarTitleView</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    )
  }
}
