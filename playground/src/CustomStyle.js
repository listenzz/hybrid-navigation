import React, { Component } from 'react';
import {
	TouchableOpacity,
	StyleSheet,
	Text,
  View,
  Image,
} from 'react-native';

import styles from './Styles'
import { RESULT_OK, Navigator } from 'react-native-navigation-hybrid'
import fontUri from './FontUtil'

const REQUEST_CODE = 1;
const ON_MENU_CLICK = 'on_menu_click';
const ON_SETTING_CLICK = 'on_setting_click';

export default class CustomStyle extends Component {

	static navigationItem = {

    titleItem: {
      title: 'Style'
    },

    leftBarButtonItem: {
      // icon: { uri: fontUri('FontAwesome', 'navicon', 24)},
      title: 'Menu',
      action: ON_MENU_CLICK,
    },

    rightBarButtonItem: {
      icon: Image.resolveAssetSource(require('./ic_settings.png')),
      title: 'SETTING',
      action: ON_SETTING_CLICK,
      enabled: false,
    },

		tabItem: {
      title: 'Style',
			icon: { uri: fontUri('FontAwesome', 'leaf', 20) },
			hideTabBarWhenPush: false,
    }
	}

	constructor(props){
		super(props);
		this.changeLeftButton = this.changeLeftButton.bind(this);
		this.changeRightButton = this.changeRightButton.bind(this);
		this.changeTitle = this.changeTitle.bind(this);
		this.hideBackButton = this.hideBackButton.bind(this);
		this.hideShadow = this.hideShadow.bind(this);
		this.passOptions = this.passOptions.bind(this);
    this.switchToTab = this.switchToTab.bind(this);
    this.toggleTabBadge = this.toggleTabBadge.bind(this);
    this.state = {
      leftButtonShowText: true,
      rightButtonEnabled: false,
      title: '样式',
      badge: null,
    }
	}
  
  onBarButtonItemClick(action) {
		console.info(action)
		if(ON_MENU_CLICK === action) {
			this.props.navigator.toggleMenu();
		}
  }

	onComponentResult(requestCode, resultCode, data) {
		
	}

	changeLeftButton() {
    if (this.state.leftButtonShowText) {
      this.props.garden.setLeftBarButtonItem({ icon: { uri: fontUri('FontAwesome', 'navicon', 24)}, })
    } else {
      this.props.garden.setLeftBarButtonItem({ title: 'Menu', icon: null })
    }
    this.setState({leftButtonShowText: !this.state.leftButtonShowText})
	}

	changeRightButton() {
    this.props.garden.setRightBarButtonItem({ enabled: !this.state.rightButtonEnabled })
    this.setState({rightButtonEnabled: !this.state.rightButtonEnabled})
	}

	changeTitle() {
    this.props.garden.setTitleItem({ title: this.state.title })
    this.setState({title: this.state.title === 'Style' ? '样式' : 'Style'})
	}

	hideBackButton() {
		this.props.navigator.push('HideBackButton');
	}

	hideShadow() {
		this.props.navigator.push('HideTopBarShadow');
	}

	passOptions() {
		this.props.navigator.push('PassOptions', {}, { titleItem: {title: 'The Passing Title'} })
	}

	switchToTab() {
		this.props.navigator.switchToTab(0);
  }
  
  toggleTabBadge() {
    if(this.state.badge) {
      this.setState({badge: null})
      this.props.navigator.setTabBadge(1, null);
    } else {
      this.setState({badge: '5'});
      this.props.navigator.setTabBadge(1, '99');
    }
    
  }

	render() {

		return (
			<View style={styles.container}>

        <Text style={styles.welcome}>
					This's a React Native scene.
        </Text>

				<TouchableOpacity onPress={this.passOptions} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						pass options to another scene
          </Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={this.hideShadow} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						hide shadow
          </Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={this.hideBackButton} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						hide back button
          </Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={this.changeLeftButton} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
            { this.state.leftButtonShowText ? 'change left button to icon' : 'change left button to text' }
          </Text>
				</TouchableOpacity>

        <TouchableOpacity onPress={this.changeRightButton} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
            { this.state.rightButtonEnabled ? 'disable right button' : 'enable right button'}
          </Text>
				</TouchableOpacity>

        <TouchableOpacity onPress={this.changeTitle} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
            { `change title to '${this.state.title}'`}
          </Text>
				</TouchableOpacity>

        <TouchableOpacity onPress={this.toggleTabBadge} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						{ this.state.badge ? 'hide tab badge' : 'show tab badge' }
          </Text>
				</TouchableOpacity>

				<TouchableOpacity onPress={this.switchToTab} activeOpacity={0.2} style={styles.button}>
					<Text style={styles.buttonText}>
						switch to tab 'Navigation'
          </Text>
				</TouchableOpacity>

			</View>
		);
	}
}