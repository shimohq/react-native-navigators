import React from 'react';
import { Text, View } from 'react-native';

export default function SplitPrimary() {
  return (
    <View style={{ flex: 1, borderColor: 'blue', borderWidth: 2, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Primary Scene</Text>
    </View>
  );
}
