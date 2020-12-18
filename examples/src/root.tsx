import React from 'react';
import { View, Text, TouchableOpacity, Platform, PlatformIOSStatic } from 'react-native';
import { NavigationInjectedProps } from 'react-navigation';

import styles from './styles';

export default function Root(props: NavigationInjectedProps) {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>react-native-navigators</Text>
      <TouchableOpacity onPress={() => props.navigation.navigate('card')}>
        <Text style={styles.link}>Card navigator demo</Text>
      </TouchableOpacity>
      <TouchableOpacity onPress={() => props.navigation.navigate('stack')}>
        <Text style={styles.link}>Stack navigator demo</Text>
      </TouchableOpacity>
      <TouchableOpacity onPress={() => props.navigation.navigate('features')}>
        <Text style={styles.link}>Features demo</Text>
      </TouchableOpacity>
    </View>
  );
}
