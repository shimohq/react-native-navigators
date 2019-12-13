import React, { ReactElement, useMemo } from 'react';
import { View, StatusBar, StyleSheet } from 'react-native';

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
    height: 56 + (StatusBar.currentHeight as number),
    paddingTop: StatusBar.currentHeight,
    width: '100%',
    backgroundColor: '#fff',
    borderBottomWidth: StyleSheet.hairlineWidth
  }
});

export default function NativeStackHeader(props: NativeStackHeaderProps) {
  const style = useMemo(() => [
    styles.container,
    { backgroundColor: props.headerBackgroundColor, borderBottomColor: props.headerBorderColor }
  ], [props.headerBackgroundColor, props.headerBorderColor]);

  return (
    <View style={style}>
      {props.children}
    </View>
  );
}

