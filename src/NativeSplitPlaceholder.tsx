import React, { ComponentType } from 'react';
import { requireNativeComponent, StyleSheet } from 'react-native';

import { NavigationInjectedProps } from 'react-navigation';

const styles = StyleSheet.create({
  container: {
    flex: 1
  }
});

export type NativeSplitPlaceholderProps = {
  component: ComponentType<NavigationInjectedProps>;
} & NavigationInjectedProps;

export default function NativeSplitPlaceholder(
  props: NativeSplitPlaceholderProps
) {
  const { component: Component, navigation } = props;
  return (
    <RNNativeSplitPlaceholder style={styles.container}>
      <Component navigation={navigation} />
    </RNNativeSplitPlaceholder>
  );
}

const RNNativeSplitPlaceholder = requireNativeComponent(
  'RNNativeSplitPlaceholder'
);
