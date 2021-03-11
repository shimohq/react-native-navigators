import React, { useEffect, useState, useContext, useCallback } from 'react';
import { Text, View, Switch, TouchableOpacity, TextInput } from 'react-native';
import { NavigationInjectedProps } from 'react-navigation';
import { NativeNavigatorTransitions, NativeSplitNavigatorOptionsContext } from 'react-native-navigators';

import styles from '../styles';

const SecondaryPrimary = function SplitSecondary(props: NavigationInjectedProps) {
  const { options: { isSplitFullScreen, splitLineColor }, setOptions } = useContext(NativeSplitNavigatorOptionsContext);
  const [fullscreen, setFullscreen] = useState(isSplitFullScreen ?? false);
  const [color, setColor] = useState(splitLineColor);

  useEffect(() => {
    setOptions({
      isSplitFullScreen: fullscreen
    });
  }, [fullscreen]);

  const onColorChanged = useCallback((value) => {
    setColor(value.nativeEvent.text);
  }, []); 

  const onChangeColor = useCallback((value) => {
    setOptions({
      splitLineColor: color
    });
  }, [color]); 

  return (
    <View style={{ flex: 1, backgroundColor: 'white', borderColor: 'blue', borderWidth: 1, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Change Split Line Color: {color} </Text>
      <TextInput style={{height: 32, width: 200, borderColor: 'red', borderWidth: 1, color: 'black'}} placeholder="input split line color" onChange={onColorChanged}></TextInput>
      <TouchableOpacity
        onPress={onChangeColor}>
        <Text style={styles.link}> Change </Text>
      </TouchableOpacity>
      
      <Text style={{marginTop: 60}} >Turn {fullscreen ? 'on' : 'off'} fullscreen</Text>
      <Switch
          value={fullscreen}
          onValueChange={() =>
            setFullscreen(!fullscreen)
          }
        />

      <TouchableOpacity
       style={{marginTop: 60}}
        onPress={() => props.navigation.goBack()}>
        <Text style={styles.link}> Go Back </Text>
      </TouchableOpacity>
    </View>
  );
}

SecondaryPrimary.navigationOptions = {
  transition: NativeNavigatorTransitions.SlideFromRight
};

export default SecondaryPrimary;
