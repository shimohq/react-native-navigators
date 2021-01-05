import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  Switch,
  StyleSheet,
  Dimensions
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
  const [on, setOn] = useState(true);
  const [enabled, setEnabled] = useState(Dimensions.get('window').width >= 640);

  useEffect(() => {
    Dimensions.addEventListener('change', ({ window: { width } }) => {
      setEnabled(width >= 640);
    })
  }, []);

  if (!enabled) {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
        <Text >
            Split Navigator is not support in this window.
        </Text>
      </View>
    )
  }

  return (
    <View style={{ flex: 1 }} >
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
      <View style={{ flex: 1, width: on ? '100%' : 639, borderColor: 'purple', borderWidth: 2, alignSelf: 'center' }} >
        <SplitNavigator {...props} />
      </View>
    </View>
  );
}

Split.navigationOptions = {};
Split.router = SplitNavigator.router;

export default Split;
