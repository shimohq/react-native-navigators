import React, { PureComponent } from 'react';
import {
  NavigationRoute,
  StackActions,
  NavigationActions
} from 'react-navigation';

import {
  NativeNavigatorsProps,
  NativeNavigatorModes
} from './types';
import NativeStackNavigator from './NativeStackNavigator';
import NativeScenes from './NativeScenes';

export default class NativeNavigators extends PureComponent<
  NativeNavigatorsProps
> {
  private handleTransitionComplete = (route: NavigationRoute) => {
    if (this.props.navigation.state.isTransitioning) {
      this.props.navigation.dispatch(
        StackActions.completeTransition({ toChildKey: route.key })
      );
    }
  };

  private handleDismissRoute = (route: NavigationRoute) => {
    this.props.navigation.dispatch({
      type: NavigationActions.BACK,
      key: route.key,
      immediate: true
    });
  };

  public render() {
    const { navigation, navigationConfig, screenProps, descriptors } = this.props;

    const mode: NativeNavigatorModes =
      navigationConfig.mode || NativeNavigatorModes.Modal;

    return (
      <NativeStackNavigator mode={mode}>
        <NativeScenes
          mode={mode}
          headerMode={navigationConfig.headerMode}
          routes={navigation.state.routes}
          descriptors={descriptors}
          navigation={navigation}
          screenProps={screenProps}
          onTransitionComplete={this.handleTransitionComplete}
          onDismissRoute={this.handleDismissRoute}
        />
      </NativeStackNavigator>
    );
  }
}
