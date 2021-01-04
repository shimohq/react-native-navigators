import React from 'react';
import {View, Text, TouchableOpacity, TextInput} from 'react-native';
import {NavigationInjectedProps} from 'react-navigation';
import {
  createNativeNavigator,
  NativeNavigatorModes,
  NativeNavigatorTransitions,
} from 'react-native-navigators';

import styles from './styles';
import {NavigateList} from './components';

function TransitionModes(props: NavigationInjectedProps) {
  const push = (transition: NativeNavigatorTransitions) => {
    props.navigation.push('transitionModes', {
      transition,
    });
  };

  return (
    <View
      style={[
        styles.container,
        {
          borderWidth: 2,
          borderColor: 'green',
        },
      ]}>
      <TouchableOpacity onPress={() => props.navigation.goBack()}>
        <Text style={styles.link}>Back to index</Text>
      </TouchableOpacity>
      <Text style={styles.title}>Card</Text>
      <Text style={styles.title}>{props.navigation.state.key}</Text>
      <TextInput
        style={[styles.input, {marginBottom: 10}]}
        placeholder="Input Text"
      />
      <NavigateList navigate={push} />
    </View>
  );
}

function Index(props: NavigationInjectedProps) {
  const navigate = (transition: NativeNavigatorTransitions) => {
    props.navigation.navigate('transitionModes', {
      transition,
    });
  };

  return (
    <View style={styles.container}>
      <TouchableOpacity
        onPress={() => props.navigation.dangerouslyGetParent().goBack()}>
        <Text style={styles.link}>Back to index</Text>
      </TouchableOpacity>
      <Text style={styles.title}>Card navigator</Text>
      <NavigateList navigate={navigate} />
    </View>
  );
}

export default createNativeNavigator(
  {
    index: Index,
    transitionModes: {
      screen: TransitionModes,
      navigationOptions: (
        props: NavigationInjectedProps<{
          transition: NativeNavigatorTransitions;
        }>,
      ) => {
        return {
          transition: props.navigation.getParam('transition'),
        };
      },
    },
  },
  {
    mode: NativeNavigatorModes.Card,
    initialRouteName: 'index',
  },
);
