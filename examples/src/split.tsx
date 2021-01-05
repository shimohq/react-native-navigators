import React, { useState } from 'react';
import {
  View,
  Text,
  Switch,
  StyleSheet,
} from 'react-native';
import { createSplitNavigator } from 'react-native-navigators';

import SplitPrimary from './screens/splitPrimary';
import SplitSecondary from './screens/splitSecondary';
import { NavigationInjectedProps } from 'react-navigation';

const SplitNavigator = createSplitNavigator({
  primary: SplitPrimary,
  secondary: SplitSecondary
}, {
  initialRouteName: 'primary',
  splitRules: [
    {
      navigatorWidthRange: [640],
      primarySceneWidth: 300
    }
  ]
});

function Split(props: NavigationInjectedProps) {
  const [enabled, setEnabled] = useState(true);

  return (
    <View >
      <View style={{ paddingVertical: 10 ,alignItems: 'center', justifyContent: 'center', flexDirection: 'row', borderBottomColor: 'red', borderBottomWidth: StyleSheet.hairlineWidth }}>
        <Text style={{ marginRight: 10 }}>
            Split Mode:{enabled ? 'ON' : 'OFF'}
        </Text>
        <Switch
          value={enabled}
          onValueChange={() =>
            setEnabled(!enabled)
          }
        />
      </View>
      <SplitNavigator {...props} />
    </View>
  );
}

Split.navigationOptions = {};
Split.router = SplitNavigator.router;

export default Split;
