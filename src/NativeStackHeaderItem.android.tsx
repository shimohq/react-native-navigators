import React, { PropsWithChildren, useMemo } from 'react';
import { View, StyleSheet } from 'react-native';

import { NativeNavigationHeaderTypes } from './types';

export interface NativeStackHeaderItemProps {
  type: NativeNavigationHeaderTypes;
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    height: 56,
    bottom: 0,
    justifyContent: 'center'
  },

  center: {
    left: 56,
    right: 56,
    alignItems: 'center'
  },

  left: {
    left: 16
  },

  right: {
    right: 16
  }
});

export default function NativeStackHeaderItem(
  props: PropsWithChildren<NativeStackHeaderItemProps>
) {
  const style = useMemo(
    () => [
      styles.container,
      props.type === NativeNavigationHeaderTypes.Center
        ? styles.center
        : props.type === NativeNavigationHeaderTypes.Left
        ? styles.left
        : styles.right
    ],
    [props.type]
  );

  return <View style={style}>{props.children}</View>;
}
