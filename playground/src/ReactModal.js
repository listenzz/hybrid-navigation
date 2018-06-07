import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableHighlight,
  TouchableWithoutFeedback,
  Dimensions,
} from 'react-native';
import * as Animatable from 'react-native-animatable';

// Utility for creating custom animations
const makeAnimation = (name, obj) => {
  Animatable.registerAnimation(name, Animatable.createAnimation(obj));
};

export default class ReactModal extends React.Component {
  static defaultProps = {
    actionSheets: [{ text: '男', onPress: () => {} }, { text: '女', onPress: () => {} }],
  };

  static navigationItem = {};

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

  handleRef = ref => {
    this.view = ref;
  };

  _onLayout = e => {
    this.height = e.nativeEvent.layout.height;
    makeAnimation('slideOutDown', {
      from: {
        opacity: 1,
        translateY: 0,
      },
      to: {
        opacity: 1,
        translateY: this.height,
      },
    });
    makeAnimation('slideInUp', {
      from: {
        opacity: 1,
        translateY: this.height,
      },
      to: {
        opacity: 1,
        translateY: 0,
      },
    });
    this.view.slideInUp(300);
  };

  hideModal() {
    console.info('hideModal');
    this.view.slideOutDown(300).then(endState => {
      if (endState.finished) {
        this.props.navigation.hideModal();
      }
    });
  }

  render() {
    return (
      <TouchableWithoutFeedback onPress={this.hideModal}>
        <Animatable.View
          ref={this.handleRef}
          useNativeDriver
          easing="ease-in-out"
          style={[styles.bottomModal, { opacity: 0 }]}
        >
          <View onLayout={this._onLayout}>
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
        </Animatable.View>
      </TouchableWithoutFeedback>
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
