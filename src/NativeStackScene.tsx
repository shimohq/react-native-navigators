import React, { PureComponent } from 'react';
import {
  requireNativeComponent,
  StyleSheet,
  StyleProp,
  ViewStyle
} from 'react-native';
import { NavigationRoute } from 'react-navigation';

import { NativeNavigatorTransitions, NativeNavigationPopover } from './types';

interface NativeStackNavigatorProps {
  closing: boolean;
  translucent: boolean;
  transparent: boolean;
  transition: NativeNavigatorTransitions;
  gestureEnabled: boolean;
  popover?: NativeNavigationPopover;
  onDidFocus: (route: NavigationRoute) => void;
  onDidBlur: (route: NavigationRoute, dismissed: boolean) => void;
  route: NavigationRoute;
  style?: StyleProp<ViewStyle>;
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
      popover,
      style
    } = this.props;

    return (
      <RNNativeStackScene
        closing={closing}
        translucent={translucent}
        transparent={transparent}
        transition={transition}
        gestureEnabled={gestureEnabled}
        popover={popover}
        onDidFocus={this.onDidFocus}
        onDidBlur={this.onDidBlur}
        style={style ? [style, StyleSheet.absoluteFill] : StyleSheet.absoluteFill}
      >
        {this.props.children}
      </RNNativeStackScene>
    );
  }
}

const RNNativeStackScene = requireNativeComponent('RNNativeStackScene');
