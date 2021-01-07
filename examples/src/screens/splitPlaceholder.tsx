import React from 'react';
import { Text, View } from 'react-native';

export default function SplitPlaceholder() {
  return (
    <View style={{ flex: 1, borderColor: 'orange', borderWidth: 2, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Primary Placeholder</Text>
    </View>
  );
}
