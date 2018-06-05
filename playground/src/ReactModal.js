import React from 'react';
import { View, Text, StyleSheet, TouchableHighlight } from 'react-native';

export default class ReactModal extends React.Component {
  static defaultProps = {
    actionSheets: [{ text: '男', onPress: () => {} }, { text: '女', onPress: () => {} }],
  };

  static navigationItem = {
    // passThroughTouches: true,
  };

  constructor(props) {
    super(props);
    this.hideModal = this.hideModal.bind(this);
  }

  renderItem = (text, onPress) => {
    return (
      <TouchableHighlight onPress={onPress} underlayColor={'#212121'}>
        <View style={styles.item}>
          <Text style={styles.itemText}>{text}</Text>
        </View>
      </TouchableHighlight>
    );
  };

  hideModal() {
    this.props.navigation.hideModal();
  }

  render() {
    return (
      <View style={styles.bottomModal}>
        {this.props.actionSheets.map(({ text, onPress }, index) => {
          let isLast = index === this.props.actionSheets.length - 1;
          return (
            <View key={text} style={!isLast && styles.divider}>
              {this.renderItem(text, onPress)}
            </View>
          );
        })}
        <View style={styles.itemCancel}>{this.renderItem('取消', this.hideModal)}</View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  bottomModal: {
    flex: 1,
    justifyContent: 'flex-end',
    margin: 0,
    //backgroundColor: '#00000000',
  },
  item: {
    height: 50,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
  },
  divider: {
    borderStyle: 'solid',
    borderBottomWidth: 0.6,
    borderBottomColor: '#DDD',
  },
  itemCancel: {
    paddingTop: 10,
    backgroundColor: '#F3F3F5',
  },
  itemText: {
    fontSize: 18,
    color: '#212121',
  },
});
