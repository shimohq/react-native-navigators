import React from 'react';
import { Text, View, TouchableOpacity } from 'react-native';
import { NavigationInjectedProps } from 'react-navigation';

import styles from '../styles';

export default function SplitIndex(props: NavigationInjectedProps) {
  return (
    <View style={{ flex: 1, backgroundColor: 'white', borderColor: 'blue', borderWidth: 2, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Index Scene</Text>
      <TouchableOpacity
        onPress={() => props.navigation.navigate('primary')}>
        <Text style={styles.link}> Navigate Split Primary </Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => props.navigation.navigate('primary1')}>
        <Text style={styles.link}> Navigate Split Primary1 </Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => props.navigation.navigate('primary2')}>
        <Text style={styles.link}> Navigate Split Primary2 </Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => props.navigation.navigate('secondary')}>
        <Text style={styles.link}> Navigate Secondary </Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => props.navigation.navigate('secondary1')}>
        <Text style={styles.link}> Navigate Secondary1 </Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => props.navigation.navigate('secondary2')}>
        <Text style={styles.link}> Navigate Secondary2 </Text>
      </TouchableOpacity>
    </View>
  );
}
