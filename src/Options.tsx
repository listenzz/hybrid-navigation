import React, { useState, useEffect } from 'react';
import { TouchableOpacity, Text, View, Image, ScrollView, PixelRatio } from 'react-native';
import Navigation, {
  withNavigationItem,
  NavigationProps,
  ImageSource,
  TabBarStyle,
  BarButtonItem,
  useVisible,
  TabItemInfo,
} from 'hybrid-navigation';

import styles from './Styles';
import getLayout from './layout';

const leftBarButtonItem: BarButtonItem = {
  icon: Image.resolveAssetSource(require('./images/menu.png')),
  title: 'Menu',
  action: navigator => {
    navigator.toggleMenu();
  },
};

export default withNavigationItem({
  titleItem: {
    title: 'Options',
  },

  leftBarButtonItem: leftBarButtonItem,

  rightBarButtonItem: {
    icon: Image.resolveAssetSource(require('./images/nav.png')),
    title: 'SETTING',
    action: navigator => {
      navigator.push('TopBarMisc');
    },
    enabled: false,
  },

  tabItem: {
    title: 'Options',
    icon: Image.resolveAssetSource(require('./images/flower_1.png')),
  },
})(Options);

function Options({ sceneId, navigator }: NavigationProps) {
  const visible = useVisible();

  useEffect(() => {
    if (!visible) {
      return;
    }

    console.info('Page Options is visible');
    Navigation.setMenuInteractive(sceneId, true);
    return () => {
      console.info('Page Options is invisible');
      Navigation.setMenuInteractive(sceneId, false);
    };
  }, [visible, sceneId]);

  useEffect(() => {
    console.info('Page Options componentDidMount');
    return () => {
      console.info('Page Options componentWillUnmount');
    };
  }, []);

  const [showsLeftBarButton, setShowsLeftBarButton] = useState(false);

  function toggleLeftBarButton() {
    setShowsLeftBarButton(!showsLeftBarButton);
  }

  useEffect(() => {
    if (showsLeftBarButton) {
      Navigation.setLeftBarButtonItem(sceneId, null);
    } else {
      Navigation.setLeftBarButtonItem(sceneId, leftBarButtonItem);
    }
  }, [showsLeftBarButton, sceneId]);

  const [rightButtonEnabled, setRightButtonEnabled] = useState(false);

  function changeRightButton() {
    setRightButtonEnabled(!rightButtonEnabled);
  }

  useEffect(() => {
    Navigation.setRightBarButtonItem(sceneId, {
      enabled: rightButtonEnabled,
    });
  }, [rightButtonEnabled, sceneId]);

  const [title, setTitle] = useState('Options');
  function changeTitle() {
    setTitle(title === 'Options' ? '配置' : 'Options');
  }

  useEffect(() => {
    Navigation.setTitleItem(sceneId, { title });
  }, [title, sceneId]);

  function passOptions() {
    navigator.push('PassOptions', {}, { titleItem: { title: 'The Passing Title' } });
  }

  function switchTab() {
    navigator.switchTab(0);
  }

  const [badges, setBadges] = useState<Array<TabItemInfo>>();

  function toggleTabBadge() {
    if (badges && badges[0].badge?.dot) {
      setBadges([
        { index: 0, badge: { hidden: true } },
        { index: 1, badge: { hidden: true } },
      ]);
    } else {
      setBadges([
        { index: 0, badge: { hidden: false, dot: true } },
        { index: 1, badge: { hidden: false, text: '99' } },
      ]);
    }
  }

  useEffect(() => {
    if (badges) {
      Navigation.setTabItem(sceneId, badges);
    }
  }, [badges, sceneId]);

  function topBarMisc() {
    navigator.push('TopBarMisc');
  }

  function lifecycle() {
    navigator.push('Lifecycle');
  }

  const [icon, setIcon] = useState<ImageSource>();

  function replaceTabIcon() {
    if (icon && icon.uri === 'flower') {
      setIcon(Image.resolveAssetSource(require('./images/flower_1.png')));
    } else {
      setIcon({ uri: 'flower', scale: PixelRatio.get() });
    }
  }

  useEffect(() => {
    if (icon) {
      Navigation.setTabItem(sceneId, {
        index: 1,
        icon: {
          selected: icon,
        },
        // title: '选项',
      });
    }
  }, [icon, sceneId]);

  const [tabItemColor, setTabItemColor] = useState<TabBarStyle>();

  function replaceTabItemColor() {
    if (tabItemColor && tabItemColor.tabBarItemColor === '#8BC34A') {
      setTabItemColor({
        tabBarItemColor: '#FF5722',
        tabBarUnselectedItemColor: '#BDBDBD',
      });
    } else {
      setTabItemColor({
        tabBarItemColor: '#8BC34A',
        tabBarUnselectedItemColor: '#BDBDBD',
      });
    }
  }

  useEffect(() => {
    if (tabItemColor) {
      Navigation.updateTabBar(sceneId, tabItemColor);
    }
  }, [tabItemColor, sceneId]);

  const [tabBarColor, setTabBarColor] = useState<TabBarStyle>();

  function updateTabBarColor() {
    if (tabBarColor && tabBarColor.tabBarColor === '#EEEEEE') {
      setTabBarColor({
        tabBarColor: '#FFFFFF',
        tabBarShadowImage: {
          color: '#F0F0F0',
        },
      });
    } else {
      setTabBarColor({
        tabBarColor: '#EEEEEE',
        tabBarShadowImage: {
          image: Image.resolveAssetSource(require('./images/divider.png')),
        },
      });
    }
  }

  useEffect(() => {
    if (tabBarColor) {
      Navigation.updateTabBar(sceneId, tabBarColor);
    }
  }, [tabBarColor, sceneId]);

  async function changeTabBar() {
    await Navigation.setRoot(getLayout());
    console.log('finish setRoot!!');
  }

  async function showModal() {
    console.info('------------------showModal--------------------------');
    const [resultCode, data] = await navigator.showModal<{ text?: string }>('ReactModal');
    console.info('------------------showModal--------------------------', resultCode, data);
  }

  function testResult() {
    setTimeout(() => showModal(), 3000);
  }

  return (
    <ScrollView
      contentInsetAdjustmentBehavior="never"
      automaticallyAdjustContentInsets={false}
      contentInset={{ top: 0, left: 0, bottom: 0, right: 0 }}>
      <View style={styles.container}>
        <Text style={styles.welcome}>This's a React Native scene.</Text>

        <TouchableOpacity onPress={topBarMisc} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>topBar options</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={lifecycle} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>Lifecycle</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={passOptions} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>pass options to another scene</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={toggleLeftBarButton} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>
            {showsLeftBarButton ? 'show left bar button' : 'hide left bar button'}
          </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={changeRightButton} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>
            {rightButtonEnabled ? 'disable right button' : 'enable right button'}
          </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={changeTitle} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>{`change title to '${
            title === 'Options' ? '配置' : 'Options'
          }'`}</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={switchTab} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>switch to tab 'Navigation'</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={toggleTabBadge} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>
            {badges && badges[0].badge?.dot ? 'hide tab badge' : 'show tab badge'}
          </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={replaceTabIcon} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>replalce tab icon</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={replaceTabItemColor} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>replalce tab item color</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={updateTabBarColor} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>change tab bar color</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={changeTabBar} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>change TabBar</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={testResult} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}>show modal</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}
