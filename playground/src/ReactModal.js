import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableHighlight,
  TouchableWithoutFeedback,
  Animated,
  Easing,
  Dimensions,
} from 'react-native';
import { RESULT_OK, Navigator } from 'react-native-navigation-hybrid';

export default class ReactModal extends React.Component {
  static navigationItem = {
    navigationBarColorAndroid: '#FFFFFF',
  };

  constructor(props) {
    super(props);
    this.hideModal = this.hideModal.bind(this);
  }

  state = {
    actionSheets: [
      {
        text: 'Male',
        onPress: async () => {
          const graph = await Navigator.routeGraph();
          console.info(graph);
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

    anim: new Animated.Value(Dimensions.get('screen').height),
  };

  componentDidMount() {
    console.info('modal componentDidMount');
  }

  componentDidAppear() {
    console.info('modal componentDidAppear');
  }

  componentDidDisappear() {
    console.info('modal componentDidDisappear');
  }

  componentWillUnmount() {
    console.info('modal componentWillUnmount');
  }

  onBackPressed = () => {
    this.hideModal();
  };

  handleCancel = () => {
    this.hideModal();
  };

  hideModal(gender) {
    console.info('hideModal:' + gender);
    Animated.timing(this.state.anim, {
      toValue: this.height,
      duration: 200,
      easing: Easing.linear,
    }).start(state => {
      console.log(state);
      this.props.navigator.setResult(RESULT_OK, {
        text: gender || 'Are you male or female?',
        backId: this.props.sceneId,
      });
      this.props.navigator.hideModal();
    });
  }

  handleLayout = e => {
    this.height = e.nativeEvent.layout.height;
    this.state.anim.setValue(this.height);
    Animated.timing(this.state.anim, { toValue: 0, duration: 200, easing: Easing.linear }).start();
  };

  handleRef = ref => {
    this.view = ref;
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
        <Animated.View
          ref={this.handleRef}
          useNativeDriver
          style={[styles.bottomModal, { opacity: 1, transform: [{ translateY: this.state.anim }] }]}
        >
          <View onLayout={this.handleLayout} style={{ backgroundColor: '#F3F3F3' }}>
            {this.state.actionSheets.map(({ text, onPress }, index) => {
              const isLast = index === this.state.actionSheets.length - 1;
              return (
                <View key={text} style={!isLast && styles.divider}>
                  {this.renderItem(text, onPress)}
                </View>
              );
            })}
            <View style={styles.itemCancel}>{this.renderItem('Cancel', this.handleCancel)}</View>
          </View>
        </Animated.View>
      </TouchableWithoutFeedback>
    );
  }
}

const styles = StyleSheet.create({
  bottomModal: {
    flex: 1,
    justifyContent: 'flex-end',
    margin: 0,
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
});
