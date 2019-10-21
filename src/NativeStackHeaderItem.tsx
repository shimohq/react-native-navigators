import React, { PropsWithChildren } from 'react';
import { requireNativeComponent, StyleSheet } from 'react-native';

import { NativeNavigationHeaderTypes } from './types';

export interface NativeStackHeaderItemProps {
  type: NativeNavigationHeaderTypes;
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0
  }
});

export default function NativeStackHeaderItem(
  props: PropsWithChildren<NativeStackHeaderItemProps>
) {
  return (
    <RNNativeStackHeaderItem type={props.type} style={styles.container}>
      {props.children}
    </RNNativeStackHeaderItem>
  );
}

const RNNativeStackHeaderItem = requireNativeComponent(
  'RNNativeStackHeaderItem'
);
