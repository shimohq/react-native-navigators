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
  onTransitionEnd: (route: NavigationRoute, closing: boolean) => void;
  onDismissed: (route: NavigationRoute) => void;
  route: NavigationRoute;
  style?: StyleProp<ViewStyle>;
}

export default class NativeStackNavigator extends PureComponent<
  NativeStackNavigatorProps
> {
  private onTransitionEnd = (event: { nativeEvent: { closing: boolean } }) => {
    this.props.onTransitionEnd(this.props.route, event.nativeEvent.closing);
  };

  private onDismissed = () => {
    this.props.onDismissed(this.props.route);
  };

  public render() {
    const {
      translucent,
      transparent,
      transition,
      gestureEnabled,
      closing,
      popover,
      style
    } = this.props;
    return (
      <RNNativeStackScene
        translucent={translucent}
        transparent={transparent}
        transition={transition}
        gestureEnabled={gestureEnabled}
        closing={closing}
        popover={popover}
        onTransitionEnd={this.onTransitionEnd}
        onDismissed={this.onDismissed}
        style={[style, StyleSheet.absoluteFill]}
      >
        {this.props.children}
      </RNNativeStackScene>
    );
  }
}

const RNNativeStackScene = requireNativeComponent('RNNativeStackScene');
