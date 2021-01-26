import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  Switch,
  StyleSheet,
  Dimensions
} from 'react-native';
import { createSplitNavigator } from 'react-native-navigators';
import { NavigationInjectedProps } from 'react-navigation';

import SplitPrimary from './screens/splitPrimary';
import SplitSecondary from './screens/splitSecondary';
import Features from './features';
import SplitPlaceholder from './screens/splitPlaceholder';

const SplitNavigatorMinWidth = 640;

const SplitNavigator = createSplitNavigator({
  primary: SplitPrimary,
  secondary: SplitSecondary,
  splitFeatures: Features
}, {
  initialRouteName: 'primary',
  splitRules: [
    {
      navigatorWidthRange: [SplitNavigatorMinWidth],
      primarySceneWidth: 300
    }
  ],
  splitPlaceholder: SplitPlaceholder
});

function Split(props: NavigationInjectedProps) {
  const [on, setOn] = useState(true);
  return (
    <View style={{ flex: 1, backgroundColor: 'white' }} >
      <View style={{ paddingVertical: 10, alignItems: 'center', justifyContent: 'center', flexDirection: 'row', borderBottomColor: 'red', borderBottomWidth: StyleSheet.hairlineWidth  }}>
        <Text style={{ marginRight: 10 }}>
            Split Mode:{on ? 'ON' : 'OFF'}
        </Text>
        <Switch
          value={on}
          onValueChange={() =>
            setOn(!on)
          }
        />
      </View>
      <View style={{ flex: 1, width: on ? '100%' : SplitNavigatorMinWidth - 20, borderColor: 'purple', borderWidth: 2, alignSelf: 'center' }} >
        <SplitNavigator {...props} />
      </View>
    </View>
  );
}

Split.navigationOptions = {};
Split.router = SplitNavigator.router;

export default Split;
