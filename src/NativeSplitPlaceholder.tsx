import React, { ComponentType } from 'react';
import { requireNativeComponent, StyleSheet } from 'react-native';

import { NavigationInjectedProps } from 'react-navigation';

export type NativeSplitPlaceholderProps = {
  component: ComponentType<NavigationInjectedProps>;
} & NavigationInjectedProps;

export default function NativeSplitPlaceholder(
  props: NativeSplitPlaceholderProps
) {
  const { component: Component, navigation } = props;
  return (
    <RNNativeSplitPlaceholder style={StyleSheet.absoluteFill}>
      <Component navigation={navigation} />
    </RNNativeSplitPlaceholder>
  );
}

const RNNativeSplitPlaceholder = requireNativeComponent(
  'RNNativeSplitPlaceholder'
);
