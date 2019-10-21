import React from 'react';
import { View, Text, TouchableOpacity, TextInput } from 'react-native';
import { NavigationInjectedProps } from 'react-navigation';
import { createNativeNavigator, NativeNavigatorModes } from 'react-native-navigators';

import styles from './styles';

function InputFocus(props: NavigationInjectedProps) {
  return (
    <View style={styles.container}>
      <TouchableOpacity onPress={() => props.navigation.push('inputFocus')}>
        <Text style={styles.link}>Push a new page with TextInput</Text>
      </TouchableOpacity>
      <TextInput style={styles.input} autoFocus={true} />
    </View>
  );
}

function FeaturesIndex(props: NavigationInjectedProps) {
  return (
    <View style={styles.container}>
      <TouchableOpacity onPress={() => props.navigation.navigate('inputFocus')}>
        <Text style={styles.link}>Scene with focused element</Text>
      </TouchableOpacity>
    </View>
  );
}

export default createNativeNavigator(
  {
    featuresIndex: {
      screen: FeaturesIndex,
      navigationOptions: (props: NavigationInjectedProps) => {
        return {
          headerLeft: (
            <TouchableOpacity
              onPress={() => props.navigation.dangerouslyGetParent().goBack()}
            >
              <Text style={styles.link}>Back</Text>
            </TouchableOpacity>
          ),
          headerCenter: <Text>Navigator features</Text>
        };
      }
    },
    inputFocus: {
      screen: InputFocus,
      navigationOptions: (props: NavigationInjectedProps) => {
        return {
          headerLeft: (
            <TouchableOpacity onPress={() => props.navigation.goBack()}>
              <Text style={styles.link}>Back</Text>
            </TouchableOpacity>
          ),
          headerCenter: <Text>Navigator Input focus test</Text>
        };
      }
    }
  },
  {
    mode: NativeNavigatorModes.Stack,
    initialRouteName: 'featuresIndex'
  }
);
