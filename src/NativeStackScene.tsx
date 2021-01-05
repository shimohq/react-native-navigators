import React, { PureComponent } from 'react';
import {
  requireNativeComponent,
  StyleSheet,
  StyleProp,
  ViewStyle
} from 'react-native';
import { NavigationRoute } from 'react-navigation';

import {
  NativeNavigatorTransitions,
  NativeNavigationStatusBarStyle
} from './types';

interface NativeStackNavigatorProps {
  closing: boolean;
  translucent: boolean;
  transparent: boolean;
  transition: NativeNavigatorTransitions;
  gestureEnabled: boolean;
  splitFullScreen: boolean;
  onDidFocus: (route: NavigationRoute) => void;
  onDidBlur: (route: NavigationRoute, dismissed: boolean) => void;
  route: NavigationRoute;
  style?: StyleProp<ViewStyle>;
  statusBarStyle?: NativeNavigationStatusBarStyle;
  statusBarHidden?: boolean;
}

export default class NativeStackNavigator extends PureComponent<
  NativeStackNavigatorProps
> {
  public componentWillUnmount() {
    this.unmounted = true;
  }

  private unmounted: boolean = false;

  private onDidFocus = () => {
    if (!this.unmounted) {
      this.props.onDidFocus(this.props.route);
    }
  };

  private onDidBlur = (event: { nativeEvent: { dismissed: boolean } }) => {
    if (!this.unmounted) {
      this.props.onDidBlur(this.props.route, event.nativeEvent.dismissed);
    }
  };

  public render() {
    const {
      closing,
      translucent,
      transparent,
      transition,
      gestureEnabled,
      style,
      statusBarStyle,
      statusBarHidden,
      splitFullScreen
    } = this.props;

    return (
      <RNNativeStackScene
        closing={closing}
        translucent={translucent}
        transparent={transparent}
        transition={transition}
        gestureEnabled={gestureEnabled}
        splitFullScreen={splitFullScreen}
        onDidFocus={this.onDidFocus}
        onDidBlur={this.onDidBlur}
        style={
          style ? [style, StyleSheet.absoluteFill] : StyleSheet.absoluteFill
        }
        statusBarStyle={statusBarStyle}
        statusBarHidden={statusBarHidden}
      >
        {this.props.children}
      </RNNativeStackScene>
    );
  }
}

const RNNativeStackScene = requireNativeComponent('RNNativeScene');
