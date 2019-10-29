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
  onWillFocus: (route: NavigationRoute) => void;
  onDidFocus: (route: NavigationRoute) => void;
  onWillBlur: (route: NavigationRoute) => void;
  onDidBlur: (route: NavigationRoute, dismissed: boolean) => void;
  route: NavigationRoute;
  style?: StyleProp<ViewStyle>;
}

export default class NativeStackNavigator extends PureComponent<
  NativeStackNavigatorProps
> {
  private onWillFocus = () => {
    this.props.onWillFocus(this.props.route);
  };

  private onDidFocus = () => {
    this.props.onDidFocus(this.props.route);
  };
  
  private onWillBlur = () => {
    this.props.onWillBlur(this.props.route);
  };

  private onDidBlur = (event: { nativeEvent: { dimissed: boolean } }) => {
    this.props.onDidBlur(this.props.route, event.nativeEvent.dimissed);
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
        onWillFocus={this.onWillFocus}
        onDidFocus={this.onDidFocus}
        onWillBlur={this.onWillBlur}
        onDidBlur={this.onDidBlur}
        style={[style, StyleSheet.absoluteFill]}
      >
        {this.props.children}
      </RNNativeStackScene>
    );
  }
}

const RNNativeStackScene = requireNativeComponent('RNNativeStackScene');
