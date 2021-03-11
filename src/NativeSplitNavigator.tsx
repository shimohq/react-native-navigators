import React, { ReactElement } from 'react';
import { StyleSheet, requireNativeComponent } from 'react-native';

import NativeStackScenes, { NativeScenesProps } from './NativeScenes';
import NativeSplitPlaceholder from './NativeSplitPlaceholder';
import { NativeNavigationSplitOptions } from './types';

export interface NativeStackNavigatorProps {
  options?: NativeNavigationSplitOptions;
  children: ReactElement<NativeScenesProps, typeof NativeStackScenes>;
}

const styles = StyleSheet.create({
  navigator: {
    flex: 1,
    overflow: 'hidden'
  }
});

export default function NativeStackNavigator(props: NativeStackNavigatorProps) {
  const { options } = props;
  return (
    <RNNativeSplitNavigator
      style={styles.navigator}
      splitRules={options?.splitRules}
      splitLineColor={options?.splitLineColor}
      isSplitFullScreen={options?.isSplitFullScreen === true}
    >
      {options?.splitPlaceholder ? (
        <NativeSplitPlaceholder component={options?.splitPlaceholder} />
      ) : null}
      {props.children}
    </RNNativeSplitNavigator>
  );
}

const RNNativeSplitNavigator = requireNativeComponent('RNNativeSplitNavigator');
