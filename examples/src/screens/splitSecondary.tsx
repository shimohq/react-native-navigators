import React, { useEffect, useState, useContext } from 'react';
import { Text, View, Switch, TouchableOpacity } from 'react-native';
import { NavigationInjectedProps } from 'react-navigation';
import { NativeSplitNavigatorOptionsContext } from 'react-native-navigators';

import styles from '../styles';

export default function SplitSecondary(props: NavigationInjectedProps) {
  const [fullscreen, setFullscreen] = useState(false);
  const { setOptions } = useContext(NativeSplitNavigatorOptionsContext);

  useEffect(() => {
    setOptions({
      isSplitFullScreen: fullscreen
    });
  }, [fullscreen]);

  return (
    <View style={{ flex: 1, backgroundColor: 'white', borderColor: 'blue', borderWidth: 2, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Turn {fullscreen ? 'on' : 'off'} fullscreen</Text>

      <Switch
          value={fullscreen}
          onValueChange={() =>
            setFullscreen(!fullscreen)
          }
        />

      <TouchableOpacity
        onPress={() => props.navigation.goBack()}>
        <Text style={styles.link}> Go Back </Text>
      </TouchableOpacity>
    </View>
  );
}

