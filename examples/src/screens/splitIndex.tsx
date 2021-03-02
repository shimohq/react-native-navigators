import React from 'react';
import { Text, View, TouchableOpacity } from 'react-native';
import { NavigationInjectedProps } from 'react-navigation';

import styles from '../styles';

function SplitIndex(props: NavigationInjectedProps) {
  return (
    <View style={{ flex: 1, borderColor: 'blue', borderWidth: 2, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Index Scene</Text>
      <TouchableOpacity
        onPress={() => props.navigation.navigate('secondary')}>
        <Text style={styles.link}> Navigate Secondary </Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => props.navigation.navigate('primary')}>
        <Text style={styles.link}> Navigate Split Primary </Text>
      </TouchableOpacity>
    </View>
  );
}

SplitIndex.navigationOptions = {
  isSplitPrimary: true
};


export default SplitIndex;
