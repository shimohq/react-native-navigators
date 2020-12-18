import React from 'react';
import { AppRegistry } from 'react-native';
import {
  createAppContainer,
  NavigationState,
  NavigationAction
} from 'react-navigation';
import {
  createNativeNavigator,
  NativeNavigatorModes,
  NativeNavigatorHeaderModes
} from 'react-native-navigators';

import Root from './root';
import CardScreen from './screens/card';
import Stack from './stack';
import Features from './features';
import { name as appName } from '../app.json';

const RootStack = createNativeNavigator(
  {
    root: Root,
    card: CardScreen,
    stack: Stack,
    features: Features
  },
  {
    mode: NativeNavigatorModes.Stack,
    headerMode: NativeNavigatorHeaderModes.None,
    initialRouteName: 'root'
  }
);

const AppContainer = createAppContainer(RootStack);

AppRegistry.registerComponent(appName, () => () => (

  <AppContainer
    onNavigationStateChange={(
      prevNavigationState: NavigationState,
      nextNavigationState: NavigationState,
      action: NavigationAction
    ) => {
      console.log(
        'navigation state changed from:',
        prevNavigationState,
        'to:',
        nextNavigationState,
        'with action:',
        action.type
      );
    }}
  />
));

