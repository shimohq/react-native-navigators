import React from 'react';
import { View, Text, TouchableOpacity, Switch } from 'react-native';
import { NavigationInjectedProps } from 'react-navigation';
import { createNativeNavigator, NativeNavigatorModes } from 'react-native-navigators';

import styles from './styles';

function StackIndex(props: NavigationInjectedProps) {
  return (
    <View style={styles.container}>
      <TouchableOpacity
        onPress={() => props.navigation.navigate('stackHeaderBorderColor')}
      >
        <Text style={styles.link}>Scene with header border color</Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => props.navigation.navigate('stackHeaderColor')}
      >
        <Text style={styles.link}>Scene with header color</Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => props.navigation.navigate('stackGesture')}
      >
        <Text style={styles.link}>gesture</Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => props.navigation.navigate('translucent')}
      >
        <Text style={styles.link}>translucent</Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => props.navigation.navigate('headerComponents')}
      >
        <Text style={styles.link}>headerComponents</Text>
      </TouchableOpacity>
    </View>
  );
}

function Gesture(props: NavigationInjectedProps) {
  const disabled = props.navigation.getParam('disabled', false);
  return (
    <View style={styles.container}>
      <Text>Gesture{disabled ? ' disabled' : ' enabled'}</Text>
      <Switch
        value={disabled}
        onValueChange={() =>
          props.navigation.setParams({
            disabled: !disabled
          })
        }
      />
    </View>
  );
}

function Color(props: NavigationInjectedProps) {
  const color = props.navigation.getParam('color', 'red');
  return (
    <View style={styles.container}>
      <View style={{ flexDirection: 'row' }}>
        <Text>Red</Text>
        <Switch
          value={color === 'red'}
          onValueChange={() =>
            props.navigation.setParams({
              color: 'red'
            })
          }
        />
      </View>
      <View style={{ flexDirection: 'row' }}>
        <Text>Blue</Text>
        <Switch
          value={color === 'blue'}
          onValueChange={() =>
            props.navigation.setParams({
              color: 'blue'
            })
          }
        />
      </View>
      <View style={{ flexDirection: 'row' }}>
        <Text>Yellow</Text>
        <Switch
          value={color === 'yellow'}
          onValueChange={() =>
            props.navigation.setParams({
              color: 'yellow'
            })
          }
        />
      </View>
    </View>
  );
}

function Translucent(props: NavigationInjectedProps) {
  const translucent = props.navigation.getParam('translucent', false);
  return (
    <View style={[styles.container, { borderColor: 'red', borderWidth: 5 }]}>
      <Text>Translucent:{translucent ? 'true' : 'false'}</Text>
      <Switch
        value={translucent}
        onValueChange={() =>
          props.navigation.setParams({
            translucent: !translucent
          })
        }
      />
    </View>
  );
}

function HeaderComponents(props: NavigationInjectedProps) {
  const headerComponents = props.navigation.getParam('headerComponents', {
    left: true,
    center: true,
    right: true
  });

  const headerHidden = props.navigation.getParam('headerHidden');
  return (
    <View style={[styles.container, styles.border]}>
      <View style={styles.item}>
        <Text>Left</Text>
        <Switch
          value={headerComponents.left}
          onValueChange={() =>
            props.navigation.setParams({
              headerComponents: {
                ...headerComponents,
                left: !headerComponents.left
              }
            })
          }
        />
      </View>
      <View style={styles.item}>
        <Text>Right</Text>
        <Switch
          value={headerComponents.right}
          onValueChange={() =>
            props.navigation.setParams({
              headerComponents: {
                ...headerComponents,
                right: !headerComponents.right
              }
            })
          }
        />
      </View>
      <View style={styles.item}>
        <Text>Center</Text>
        <Switch
          value={headerComponents.center}
          onValueChange={() =>
            props.navigation.setParams({
              headerComponents: {
                ...headerComponents,
                center: !headerComponents.center
              }
            })
          }
        />
      </View>
      <View style={styles.item}>
        <Text>Hidden</Text>
        <Switch
          value={headerHidden}
          onValueChange={() =>
            props.navigation.setParams({
              headerHidden: !headerHidden
            })
          }
        />
      </View>
    </View>
  );
}

export default createNativeNavigator(
  {
    stackIndex: {
      screen: StackIndex,
      navigationOptions: (props: NavigationInjectedProps) => {
        return {
          headerLeft: (
            <TouchableOpacity
              onPress={() => {
                const parent = props.navigation.dangerouslyGetParent();
                if (parent) {
                  parent.goBack();
                }
              }}
            >
              <Text style={styles.link}>Back</Text>
            </TouchableOpacity>
          ),
          headerCenter: <Text>Stack Navigator</Text>
        };
      }
    },
    stackHeaderBorderColor: {
      screen: Color,
      navigationOptions: (props: NavigationInjectedProps) => {
        return {
          headerLeft: (
            <TouchableOpacity onPress={() => props.navigation.goBack()}>
              <Text style={styles.link}>Back</Text>
            </TouchableOpacity>
          ),
          headerCenter: <Text>Green header border color</Text>,
          headerBorderColor: props.navigation.getParam('color', 'red')
        };
      }
    },
    stackHeaderColor: {
      screen: Color,
      navigationOptions: (props: NavigationInjectedProps) => {
        return {
          headerLeft: (
            <TouchableOpacity onPress={() => props.navigation.goBack()}>
              <Text style={styles.link}>Back</Text>
            </TouchableOpacity>
          ),
          headerCenter: <Text>Header color</Text>,
          headerBackgroundColor: props.navigation.getParam('color', 'red')
        };
      }
    },
    stackGesture: {
      screen: Gesture,
      navigationOptions: (props: NavigationInjectedProps) => {
        const disabled = props.navigation.getParam('disabled', false);
        return {
          headerLeft: (
            <TouchableOpacity onPress={() => props.navigation.goBack()}>
              <Text style={styles.link}>Back</Text>
            </TouchableOpacity>
          ),
          gestureEnabled: !disabled,
          headerCenter: (
            <Text>Gesture{disabled ? ' disabled' : ' enabled'}</Text>
          )
        };
      }
    },
    translucent: {
      screen: Translucent,
      navigationOptions: (props: NavigationInjectedProps) => {
        return {
          translucent: props.navigation.getParam('translucent', false)
        };
      }
    },
    headerComponents: {
      screen: HeaderComponents,
      navigationOptions: (props: NavigationInjectedProps) => {
        const headerComponents = props.navigation.getParam('headerComponents', {
          left: true,
          center: true,
          right: true
        });
        const headerHidden = props.navigation.getParam('headerHidden', false);
        return {
          headerLeft: headerComponents.left ? (
            <Text style={styles.border}>Left</Text>
          ) : null,
          headerCenter: headerComponents.center ? (
            <Text style={styles.border}>Center</Text>
          ) : null,
          headerRight: headerComponents.right ? (
            <Text style={styles.border}>Right</Text>
          ) : null,
          headerHidden
        };
      }
    }
  },
  {
    mode: NativeNavigatorModes.Stack,
    initialRouteName: 'stackIndex'
  }
);
