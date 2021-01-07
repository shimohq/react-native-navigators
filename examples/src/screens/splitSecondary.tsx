import React, { useEffect, useState } from 'react';
import { Text, View, Switch } from 'react-native';
import { NavigationInjectedProps } from 'react-navigation';
import { NativeNavigationOptions } from 'react-native-navigators';

function SplitSecondary(props: NavigationInjectedProps) {
  const [fullscreen, setFullscreen] = useState(false);


  useEffect(() => {
    props.navigation.setParams({
      fullscreen
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
    </View>
  );
}

SplitSecondary.navigationOptions = (props: NavigationInjectedProps): NativeNavigationOptions => {
  return {
    splitFullScreen: props.navigation.getParam('fullscreen')
  }
}

export default SplitSecondary;
