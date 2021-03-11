import React from 'react';
import { Text, View, TouchableOpacity } from 'react-native';
import { useNavigation } from 'react-navigation-hooks';

export default function SplitPlaceholder() {
  const navigation = useNavigation();
  return (
    <View style={{ flex: 1, backgroundColor: 'white', borderColor: 'orange', borderWidth: 1, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Primary Placeholder</Text>
      <TouchableOpacity onPress={() => navigation.navigate('secondary')}><Text>Go to secondary scene</Text></TouchableOpacity>
    </View>
  );
}
