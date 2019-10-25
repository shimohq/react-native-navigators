import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import {
  NativeNavigatorTransitions
} from 'react-native-navigators';

import styles from '../styles';


export function NavigateList({
                        navigate
                      }: {
  navigate: (transition: NativeNavigatorTransitions) => void;
}) {
  return (
    <View style={{ marginBottom: 10 }}>
      <TouchableOpacity
        onPress={() => navigate(NativeNavigatorTransitions.Default)}
      >
        <Text style={styles.link}>⬆️Navigate by default</Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => navigate(NativeNavigatorTransitions.None)}
      >
        <Text style={styles.link}>❌Navigate with no transition</Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => navigate(NativeNavigatorTransitions.SlideFromBottom)}
      >
        <Text style={styles.link}>⬆️Navigate from bottom</Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => navigate(NativeNavigatorTransitions.SlideFromRight)}
      >
        <Text style={styles.link}>⬅️Navigate from right</Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => navigate(NativeNavigatorTransitions.SlideFromLeft)}
      >
        <Text style={styles.link}>➡️Navigate from left</Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => navigate(NativeNavigatorTransitions.SlideFromTop)}
      >
        <Text style={styles.link}>⬇️Navigate from top</Text>
      </TouchableOpacity>
    </View>
  );
}
