import React, { Component } from 'react'
import { StyleSheet, Text, View, TouchableOpacity } from 'react-native'
import Toast from 'react-native-toast-hybrid'

export default class ToastComponent extends Component {
  static navigationItem = {
    titleItem: {
      title: 'Toast',
    },
  }

  constructor(props) {
    super(props)
    this.timer = undefined
  }

  componentDidMount() {
    Toast.config({
      // backgroundColor: '#BB000000',
      // tintColor: '#FFFFFF',
      // cornerRadius: 5, // only for android
      // duration: 2000,
      // graceTime: 300,
      // minShowTime: 800,
      // dimAmount: 0.0, // only for andriod
      loadingText: 'Loading...',
    })
  }

  componentWillUnmount() {
    if (this.timer) {
      clearTimeout(this.timer)
    }
  }

  loading = () => {
    this.props.toast.loading()
    this.timer = setTimeout(() => {
      this.props.toast.done('Work is done!')
      this.timer = setTimeout(() => {
        this.props.toast.loading('New task in progress...')
        this.timer = setTimeout(() => {
          this.timer = undefined
          this.props.toast.hide()
        }, 2000)
      }, 1500)
    }, 2000)
  }

  text = () => {
    this.props.toast.text('Hello World!!')
  }

  info = () => {
    this.props.toast.info(
      'A long long message to tell you, A long long message to tell you, A long long message to tell you',
    )
  }

  done = () => {
    this.props.toast.done('Work is Done！')
  }

  error = () => {
    this.props.toast.error('Maybe somthing is wrong！')
  }

  render() {
    return (
      <View style={styles.container}>
        <TouchableOpacity onPress={this.loading} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> loading </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.text} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> text </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.info} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> info </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.done} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> done </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.error} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> error </Text>
        </TouchableOpacity>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'flex-start',
    alignItems: 'stretch',
    paddingTop: 16,
  },

  button: {
    alignItems: 'center',
    justifyContent: 'center',
    height: 40,
  },

  buttonText: {
    backgroundColor: 'transparent',
    color: 'rgb(34,88,220)',
  },

  text: {
    backgroundColor: 'transparent',
    fontSize: 16,
    alignSelf: 'flex-start',
    textAlign: 'left',
    margin: 8,
  },
})
