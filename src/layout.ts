import { Tabs } from 'hybrid-navigation';

let tabLayoutStyle = 'custom';

export default function getLayout() {
  const navigationStack = {
    stack: {
      children: [{ screen: { moduleName: 'Navigation' } }],
    },
  };

  const optionsStack = {
    stack: {
      children: [{ screen: { moduleName: 'Options' } }],
    },
  };

  let options: Tabs['tabs']['options'] = { selectedIndex: 1 };
  if (tabLayoutStyle === 'bulge') {
    tabLayoutStyle = 'normal';
    options = {
      tabBarModuleName: 'BulgeTabBar',
      sizeIndeterminate: true,
      selectedIndex: 1,
    };
  } else if (tabLayoutStyle === 'custom') {
    tabLayoutStyle = 'bulge';
    options = {
      tabBarModuleName: 'CustomTabBar',
      sizeIndeterminate: false,
      selectedIndex: 1,
    };
  } else {
    tabLayoutStyle = 'custom';
    options = {
      selectedIndex: 1,
    };
  }

  const tabs: Tabs = {
    tabs: {
      children: [navigationStack, optionsStack],
      options: options,
    },
  };

  const menu = { screen: { moduleName: 'Menu' } };

  const drawer = {
    drawer: {
      children: [tabs, menu],
      options: {
        maxDrawerWidth: 280,
        minDrawerMargin: 64,
      },
    },
  };
  return drawer;
}
