import React from 'react';
import { Text, View, TouchableOpacity } from 'react-native';
import { NavigationInjectedProps } from 'react-navigation';

export default function SplitPlaceholder(props: NavigationInjectedProps) {
  return (
    <View style={{ flex: 1, borderColor: 'orange', borderWidth: 2, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Primary Placeholder</Text>
      <TouchableOpacity onPress={() => props.navigation.navigate('secondary')}><Text>Go to secondary scene</Text></TouchableOpacity>
    </View>
  );
}
