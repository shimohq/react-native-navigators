import React from 'react';
import { Text, View, TouchableOpacity } from 'react-native';
import { NavigationInjectedProps } from 'react-navigation';

import styles from '../styles';

export default function SplitPrimary(props: NavigationInjectedProps) {
  return (
    <View style={{ flex: 1, borderColor: 'blue', borderWidth: 2, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Primary Scene</Text>
      <TouchableOpacity
        onPress={() => props.navigation.navigate('secondary')}>
        <Text style={styles.link}> Navigate Secondary </Text>
      </TouchableOpacity>
    </View>
  );
}
