import React, { ReactElement } from 'react';
import { requireNativeComponent, StyleSheet } from 'react-native';

import NativeStackHeaderItem, {
  NativeStackHeaderItemProps
} from './NativeStackHeaderItem';

interface NativeStackHeaderProps {
  children: Array<ReactElement<
    NativeStackHeaderItemProps,
    typeof NativeStackHeaderItem
  > | null>;
  headerBackgroundColor?: string;
  headerBorderColor?: string;
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0
  }
});

export default function NativeStackHeader(props: NativeStackHeaderProps) {
  return <RNNativeStackHeader {...props} style={styles.container} />;
}

const RNNativeStackHeader = requireNativeComponent('RNNativeStackHeader');
