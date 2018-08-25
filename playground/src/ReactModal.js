import React from 'react';
import { View, Text, StyleSheet, TouchableHighlight, TouchableWithoutFeedback } from 'react-native';
import * as Animatable from 'react-native-animatable';
import { RESULT_OK } from 'react-native-navigation-hybrid';

// Utility for creating custom animations
const makeAnimation = (name, obj) => {
  Animatable.registerAnimation(name, Animatable.createAnimation(obj));
};

export default class ReactModal extends React.Component {
  constructor(props) {
    super(props);
    this.hideModal = this.hideModal.bind(this);
  }

  state = {
    actionSheets: [
      {
        text: 'Male',
        onPress: () => {
          this.hideModal('Male');
        },
      },
      {
        text: 'Female',
        onPress: () => {
          this.hideModal('Female');
        },
      },
    ],
  };

  onBackPressed = () => {
    this.handleCancel();
  };

  handleCancel = () => {
    this.hideModal();
  };

  hideModal(gender) {
    console.info('hideModal:' + gender);
    this.view.slideOutDown(250).then(endState => {
      if (endState.finished) {
        this.props.navigator.setResult(RESULT_OK, {
          text: gender || 'Are you male or female?',
          backId: this.props.sceneId,
        });
        this.props.navigator.hideModal();
      }
    });
  }

  handleRef = ref => {
    this.view = ref;
  };

  onLayout = e => {
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
    this.view.slideInUp(250);
  };

  renderItem = (text, onPress) => {
    return (
      <TouchableHighlight onPress={onPress} underlayColor={'#212121'}>
        <View style={styles.item}>
          <Text style={styles.itemText}>{text}</Text>
        </View>
      </TouchableHighlight>
    );
  };

  render() {
    return (
      <TouchableWithoutFeedback onPress={this.handleCancel}>
        <Animatable.View
          ref={this.handleRef}
          useNativeDriver
          easing="ease-in-out"
          style={[styles.bottomModal, { opacity: 0 }]}
        >
          <View onLayout={this.onLayout}>
            {this.state.actionSheets.map(({ text, onPress }, index) => {
              let isLast = index === this.state.actionSheets.length - 1;
              return (
                <View key={text} style={!isLast && styles.divider}>
                  {this.renderItem(text, onPress)}
                </View>
              );
            })}
            <View style={styles.itemCancel}>{this.renderItem('Cancel', this.handleCancel)}</View>
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
