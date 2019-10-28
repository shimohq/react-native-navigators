import { View } from 'react-native';
import CardNavigator from '../card';
import React, {PureComponent} from 'react';

export default class CardScreen extends PureComponent {
  public static navigationOptions = {};
  public static router = CardNavigator.router;

  public render() {
    return (
      <View
        style={{
          flex: 1,
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: 'rgba(0, 0, 0, 0.4)'
        }}
      >
        <View
          style={{
            width: 300,
            height: 310,
            backgroundColor: 'red'
          }}
        >
          <CardNavigator {...this.props} />
        </View>
      </View>
    );
  }
}
