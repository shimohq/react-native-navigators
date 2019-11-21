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
    if (!this.dismissed) {
      this.props.onDidBlur(this.props.route, true);
    }
  }

  private dismissed: boolean = false;

  private onDidFocus = () => {
    if (!this.dismissed) {
      this.props.onDidFocus(this.props.route);
    }
  };

  private onDidBlur = (event: { nativeEvent: { dismissed: boolean } }) => {
    if (!this.dismissed) {
      this.props.onDidBlur(this.props.route, event.nativeEvent.dismissed);
      this.dismissed = event.nativeEvent.dismissed;
    }
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
        onDidFocus={this.onDidFocus}
        onDidBlur={this.onDidBlur}
        style={[style, StyleSheet.absoluteFill]}
      >
        {this.props.children}
      </RNNativeStackScene>
    );
  }
}

const RNNativeStackScene = requireNativeComponent('RNNativeStackScene');
