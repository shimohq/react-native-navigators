import React from 'react';
import {View, Text, TouchableOpacity, StyleSheet} from 'react-native';
import { NavigationInjectedProps } from 'react-navigation';
import {
  createNativeNavigator,
  NativeNavigatorModes,
  NativeNavigatorTransitions,
  NativeNavigatorDirection
} from 'react-native-navigators';

import styles from './styles';
const absoluteFill = StyleSheet.absoluteFill;

const ContentWidth = 300;
const ContentHeight = 400;
const NativeID = 'popover:index';

function NavigateList({
                        navigate
                      }: {
  navigate: (directions: NativeNavigatorDirection[]) => void;
}) {
  return (
    <View style={{ marginBottom: 10 }}>
      <View nativeID={NativeID} style={{backgroundColor: 'red'}}>
        <Text >
          Popover Source View
        </Text>
      </View>
      <TouchableOpacity
        onPress={() => navigate([NativeNavigatorDirection.Up])}
      >
        <Text style={styles.link}>
          ⬆ Arrow direction - up
        </Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => navigate([NativeNavigatorDirection.Down])}
      >
        <Text style={styles.link}>
          ⬇ Arrow direction - down
        </Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => navigate([NativeNavigatorDirection.Left])}
      >
        <Text style={styles.link}>
          ⬅ Arrow direction - left
        </Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => navigate([NativeNavigatorDirection.Right])}
      >
        <Text style={styles.link}>
          ➡ Arrow direction - right
        </Text>
      </TouchableOpacity>
    </View>
  );
}

function PopoverTransitionModes(props: NavigationInjectedProps) {
  return (
    <View
      style={[
        absoluteFill,
        {
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: 'rgba(255, 255, 255, 0.75)',
          borderWidth: 2,
          borderColor: 'green'
        }
      ]}
    >
      <TouchableOpacity onPress={() => props.navigation.goBack()}>
        <Text style={styles.link}>Back to index</Text>
      </TouchableOpacity>
      <Text style={styles.title}>Popover</Text>
      <Text style={styles.title}>{props.navigation.state.key}</Text>
    </View>
  );
}

function PopoverIndex(props: NavigationInjectedProps) {
  const navigate = (directions?: NativeNavigatorDirection[]) => {
    props.navigation.navigate('popoverTransitionModes', {
      directions
    });
  };

  return (
    <View style={styles.container}>
      <TouchableOpacity
        onPress={() => props.navigation.dangerouslyGetParent().goBack()}
      >
        <Text style={styles.link}>Back to index</Text>
      </TouchableOpacity>
      <Text style={styles.title}>Popover navigator for iPad</Text>
      <NavigateList navigate={navigate}/>
    </View>
  );
}

export default createNativeNavigator(
  {
    popoverIndex: PopoverIndex,
    popoverTransitionModes: {
      screen: PopoverTransitionModes,
      navigationOptions: (
        props: NavigationInjectedProps<{
          transition: NativeNavigatorTransitions;
          directions?: NativeNavigatorDirection[];
          nativeID: string;
        }>
      ) => {
        return {
          popover:{
            sourceViewNativeID: NativeID,
            contentSize: {
              width:ContentWidth,
              height:ContentHeight
            },
            sourceRect: {
              x:0,
              y:0,
              width:10,
              height:10
            },
            directions: props.navigation.getParam('directions')
          }
        };
      }
    }
  },
  {
    mode: NativeNavigatorModes.Modal,
    initialRouteName: 'popoverIndex'
  }
);
