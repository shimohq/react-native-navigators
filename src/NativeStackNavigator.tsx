import React, { ReactElement, useState } from 'react';
import { requireNativeComponent, StyleSheet } from 'react-native';

import NativeStackScenes, { NativeScenesProps } from './NativeScenes';
import { NativeNavigatorModes } from './types';

interface NativeStackNavigatorProps {
  mode: NativeNavigatorModes;
  children: ReactElement<NativeScenesProps, typeof NativeStackScenes>;
}

const styles = StyleSheet.create({
  navigator: {
    flex: 1
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
  if (mode === NativeNavigatorModes.Modal) {
    Navigator = RNNativeModalNavigator;
  } else {
    Navigator = RNNativeStackNavigator;
  }

  return <Navigator style={styles.navigator}>{props.children}</Navigator>;
}

const RNNativeStackNavigator = requireNativeComponent('RNNativeStackNavigator');
const RNNativeModalNavigator = requireNativeComponent('RNNativeModalNavigator');
