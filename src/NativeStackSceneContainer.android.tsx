import React, { ReactNode } from 'react';
import { View, StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column-reverse'
  }
});

export default function NativeStackSceneContainer(props: {
  children: ReactNode;
}) {
  return (
    <View style={styles.container} collapsable={false}>
      {props.children}
    </View>
  );
}
