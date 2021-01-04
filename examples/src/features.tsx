import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  TextInput,
  Switch,
  Picker,
} from 'react-native';
import {NavigationInjectedProps, StackActions} from 'react-navigation';
import {
  createNativeNavigator,
  NativeNavigatorModes,
} from 'react-native-navigators';

import styles from './styles';
import {NativeNavigationStatusBarStyle} from 'react-native-navigators/lib';

function InputFocus(props: NavigationInjectedProps) {
  return (
    <View style={styles.container}>
      <TouchableOpacity onPress={() => props.navigation.dispatch(StackActions.push({routeName: 'inputFocus'}))}>
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
      <TouchableOpacity
        onPress={() =>
          props.navigation.navigate('statusBar', {statusBarHidden: false})
        }>
        <Text style={styles.link}>Status bar - Show</Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() =>
          props.navigation.navigate('statusBar', {statusBarHidden: true})
        }>
        <Text style={styles.link}>Status bar - Hidden</Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() =>
          props.navigation.navigate('statusBar', {
            statusBarStyle: NativeNavigationStatusBarStyle.Default,
          })
        }>
        <Text style={styles.link}>Status bar style - Default</Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() =>
          props.navigation.navigate('statusBar', {
            statusBarStyle: NativeNavigationStatusBarStyle.DarkContent,
          })
        }>
        <Text style={styles.link}>Status bar style - Dark Content</Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() =>
          props.navigation.navigate('statusBar', {
            statusBarStyle: NativeNavigationStatusBarStyle.LightContent,
          })
        }>
        <Text style={styles.link}>Status bar style - Light Content</Text>
      </TouchableOpacity>
    </View>
  );
}

function StatusBar(props: NavigationInjectedProps) {
  const {
    navigation: {
      setParams,
      state: {params},
    },
  } = props;
  const {statusBarStyle, statusBarHidden} = params || {};
  return (
    <View style={[styles.container, {borderColor: 'red', borderWidth: 5}]}>
      <Text>statusBarHidden:{statusBarHidden ? 'true' : 'false'}</Text>
      <Switch
        value={statusBarHidden}
        onValueChange={() =>
          setParams({
            statusBarHidden: !statusBarHidden,
          })
        }
      />
      <Text style={{marginTop: 100}}>
        statusBarStyle:
        {statusBarStyle || NativeNavigationStatusBarStyle.Default}
      </Text>
      <Picker
        style={{width: 200}}
        selectedValue={statusBarStyle || NativeNavigationStatusBarStyle.Default}
        onValueChange={value =>
          setParams({
            statusBarStyle: value,
          })
        }>
        <Picker.Item
          label="Default"
          value={NativeNavigationStatusBarStyle.Default}
        />
        <Picker.Item
          label="Light Content"
          value={NativeNavigationStatusBarStyle.LightContent}
        />
        <Picker.Item
          label="Dark Content"
          value={NativeNavigationStatusBarStyle.DarkContent}
        />
      </Picker>
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
              onPress={() => props.navigation.dangerouslyGetParent()?.goBack()}>
              <Text style={styles.link}>Back</Text>
            </TouchableOpacity>
          ),
          headerCenter: <Text>Navigator features</Text>,
        };
      },
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
          headerCenter: <Text>Navigator Input focus test</Text>,
        };
      },
    },
    statusBar: {
      screen: StatusBar,
      navigationOptions: (props: NavigationInjectedProps) => {
        return {
          headerLeft: (
            <TouchableOpacity onPress={() => props.navigation.goBack()}>
              <Text style={styles.link}>Back</Text>
            </TouchableOpacity>
          ),
          statusBarStyle: props.navigation.getParam('statusBarStyle'),
          statusBarHidden: props.navigation.getParam('statusBarHidden'),
        };
      },
    },
  },
  {
    mode: NativeNavigatorModes.Stack,
    initialRouteName: 'featuresIndex',
  },
);
