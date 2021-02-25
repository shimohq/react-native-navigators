import React, { ElementType } from 'react';
import { requireNativeComponent, StyleSheet } from 'react-native';

export type NativeSplitPlaceholderProps = {
  component: ElementType<{}>;
};

export default function NativeSplitPlaceholder(
  props: NativeSplitPlaceholderProps
) {
  const { component: Component } = props;
  return (
    <RNNativeSplitPlaceholder style={StyleSheet.absoluteFill}>
      <Component />
    </RNNativeSplitPlaceholder>
  );
}

const RNNativeSplitPlaceholder = requireNativeComponent(
  'RNNativeSplitPlaceholder'
);
