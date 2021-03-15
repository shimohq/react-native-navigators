import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  Switch,
  StyleSheet,
} from 'react-native';
import { createSplitNavigator } from 'react-native-navigators';
import { NavigationInjectedProps } from 'react-navigation';

import SplitIndex from './screens/splitIndex';
import SplitSecondary from './screens/splitSecondary';
import SplitPlaceholder from './screens/splitPlaceholder';
import SplitPrimary from './screens/splitPrimary';

const SplitNavigatorMinWidth = 640;

const SplitNavigator = createSplitNavigator({
  index: SplitIndex,
  primary: SplitPrimary,
  primary1: SplitPrimary,
  primary2: SplitPrimary,
  secondary: SplitSecondary,
  secondary1: SplitSecondary,
  secondary2: SplitSecondary,
}, {
  initialRouteName: 'index',
  defaultContextOptions: {
    splitRules: [
      {
        navigatorWidthRange: [SplitNavigatorMinWidth],
        primarySceneWidth: 300
      }
    ],
    splitPlaceholder: SplitPlaceholder,
    splitLineColor: 'blue',
    splitPrimaryRouteNames: ['index', 'primary', 'primary1', 'primary2']
  }
 
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
