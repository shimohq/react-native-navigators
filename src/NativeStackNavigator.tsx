import React, { ReactElement, useState } from 'react';
import { requireNativeComponent, StyleSheet } from 'react-native';

import NativeStackScenes, { NativeScenesProps } from './NativeScenes';
import { NativeNavigatorModes, NativeNavigatorSplitRules } from './types';

interface NativeStackNavigatorProps {
  mode: NativeNavigatorModes;
  splitRules?: NativeNavigatorSplitRules;
  children: ReactElement<NativeScenesProps, typeof NativeStackScenes>;
}

const styles = StyleSheet.create({
  navigator: {
    flex: 1,
    overflow: 'hidden'
  }
});

export default function NativeStackNavigator(props: NativeStackNavigatorProps) {
  const [mode] = useState(props.mode);

  if (mode !== props.mode) {
    throw new Error(
      'NativeStackNavigator `mode` prop has been changed, the NativeStackNavigator mode should be constant。'
    );
  }

  let Navigator;
  switch (mode) {
    case NativeNavigatorModes.Card:
      Navigator = RNNativeCardNavigator;
      break;
    case NativeNavigatorModes.Split:
      Navigator = RNNativeSplitNavigator;
      break;
    default:
      Navigator = RNNativeStackNavigator;
      break;
  }
  return (
    <Navigator style={styles.navigator} splitRules={props.splitRules}>
      {props.children}
    </Navigator>
  );
}

const RNNativeStackNavigator = requireNativeComponent('RNNativeStackNavigator');
const RNNativeSplitNavigator = requireNativeComponent('RNNativeSplitNavigator');
const RNNativeCardNavigator = requireNativeComponent('RNNativeCardNavigator');
