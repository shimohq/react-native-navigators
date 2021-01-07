import React, { ReactElement, ComponentType, useState } from 'react';
import { StyleSheet, requireNativeComponent } from 'react-native';
import { NavigationInjectedProps } from 'react-navigation';

import NativeStackScenes, { NativeScenesProps } from './NativeScenes';
import NativeSplitPlaceholder from './NativeSplitPlaceholder';
import { NativeNavigatorModes, NativeNavigatorSplitRules } from './types';

export interface NativeStackNavigatorProps extends NavigationInjectedProps {
  mode: NativeNavigatorModes;
  splitRules?: NativeNavigatorSplitRules;
  splitPlaceholder?: ComponentType<NavigationInjectedProps>;
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

  const { splitPlaceholder, navigation } = props;

  return (
    <Navigator style={styles.navigator} splitRules={props.splitRules}>
      {splitPlaceholder ? (
        <NativeSplitPlaceholder
          navigation={navigation}
          component={splitPlaceholder}
        />
      ) : null}
      {props.children}
    </Navigator>
  );
}

const RNNativeStackNavigator = requireNativeComponent('RNNativeStackNavigator');
const RNNativeSplitNavigator = requireNativeComponent('RNNativeSplitNavigator');
const RNNativeCardNavigator = requireNativeComponent('RNNativeCardNavigator');
