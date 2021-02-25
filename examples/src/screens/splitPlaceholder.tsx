import React from 'react';
import { Text, View, TouchableOpacity } from 'react-native';
import { useNavigation } from 'react-navigation-hooks';

export default function SplitPlaceholder() {
  const navigation = useNavigation();
  return (
    <View style={{ flex: 1, borderColor: 'orange', borderWidth: 2, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Primary Placeholder</Text>
      <TouchableOpacity onPress={() => navigation.navigate('secondary')}><Text>Go to secondary scene</Text></TouchableOpacity>
    </View>
  );
}
