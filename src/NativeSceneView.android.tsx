import { View, StyleSheet } from 'react-native';
import {  SceneView, SceneViewProps } from 'react-navigation';

const styles = StyleSheet.create({
  container: {
    flex: 1
  }
});

export default function(props: SceneViewProps) {
  return (
    <View style={styles.container}>
      <SceneView {...props} />
    </View>
  )
}
