import React from 'react';
import { Text, View, TouchableOpacity } from 'react-native';
import { NavigationInjectedProps } from 'react-navigation';

import styles from '../styles';

function SplitPrimary(props: NavigationInjectedProps) {
  return (
    <View style={{ flex: 1, backgroundColor: 'red', borderColor: 'blue', borderWidth: 2, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Primary Scene</Text>
      <TouchableOpacity
        onPress={() => props.navigation.goBack()}>
        <Text style={styles.link}> Go Back </Text>
      </TouchableOpacity>
    </View>
  );
}

SplitPrimary.navigationOptions = {
  isSplitPrimary: true
};

export default SplitPrimary;
