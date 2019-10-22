import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { NavigationInjectedProps } from 'react-navigation';
import {
  createNativeNavigator,
  NativeNavigatorModes,
  NativeNavigatorTransitions
} from 'react-native-navigators';

import styles from './styles';

function NavigateList({
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

function ModalTransitionModes(props: NavigationInjectedProps) {
  const push = (transition: NativeNavigatorTransitions) => {
    props.navigation.push('modalTransitionModes', {
      transition
    });
  };

  return (
    <View
      style={[
        styles.container,
        {
          backgroundColor: 'rgba(255, 255, 255, 0.75)',
          borderWidth: 2,
          borderColor: 'green'
        }
      ]}
    >
      <TouchableOpacity onPress={() => props.navigation.goBack()}>
        <Text style={styles.link}>Back to index</Text>
      </TouchableOpacity>
      <Text style={styles.title}>Modal</Text>
      <Text style={styles.title}>{props.navigation.state.key}</Text>
      <NavigateList navigate={push} />
    </View>
  );
}

function ModalIndex(props: NavigationInjectedProps) {
  const navigate = (transition: NativeNavigatorTransitions) => {
    props.navigation.navigate('modalTransitionModes', {
      transition
    });
  };

  return (
    <View style={styles.container}>
      <TouchableOpacity
        onPress={() => props.navigation.dangerouslyGetParent().goBack()}
      >
        <Text style={styles.link}>Back to index</Text>
      </TouchableOpacity>
      <Text style={styles.title}>Modal navigator</Text>
      <NavigateList navigate={navigate} />
    </View>
  );
}

export default createNativeNavigator(
  {
    modalIndex: ModalIndex,
    modalTransitionModes: {
      screen: ModalTransitionModes,
      navigationOptions: (
        props: NavigationInjectedProps<{
          transition: NativeNavigatorTransitions;
        }>
      ) => {
        return {
          transition: props.navigation.getParam('transition')
        };
      }
    }
  },
  {
    mode: NativeNavigatorModes.Modal,
    initialRouteName: 'modalIndex'
  }
);
