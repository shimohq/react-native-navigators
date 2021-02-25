import React, { ReactElement } from 'react';
import { StyleSheet, requireNativeComponent } from 'react-native';

import NativeStackScenes, { NativeScenesProps } from './NativeScenes';

export interface NativeStackNavigatorProps {
  children: ReactElement<NativeScenesProps, typeof NativeStackScenes>;
}

const styles = StyleSheet.create({
  navigator: {
    flex: 1,
    overflow: 'hidden'
  }
});

export default function NativeStackNavigator(props: NativeStackNavigatorProps) {
  return (
    <RNNativeCardNavigator style={styles.navigator}>
      {props.children}
    </RNNativeCardNavigator>
  );
}

const RNNativeCardNavigator = requireNativeComponent('RNNativeCardNavigator');
