import { ReactNode, ComponentType } from 'react';
import { StyleProp, ViewStyle, TextStyle } from 'react-native';
import {
  NavigationParams,
  NavigationDescriptor,
  NavigationInjectedProps,
  NavigationScreenConfig
} from 'react-navigation';

export interface NativeNavigationOptions {
  transition?: NativeNavigatorTransitions;
  translucent?: boolean;
  transparent?: boolean;
  cardStyle?: StyleProp<ViewStyle>;
  splitFullScreen?: boolean; // Options for secondary scene in split navigator
  gestureEnabled?: boolean;
  headerLeft?: ReactNode;
  headerCenter?: ReactNode;
  headerRight?: ReactNode;
  headerBackgroundColor?: string;
  headerBorderColor?: string;
  headerHidden?: boolean;
  headerTitle?: string;
  headerTitleStyle?: StyleProp<TextStyle>;
  statusBarStyle?: NativeNavigationStatusBarStyle;
  statusBarHidden?: boolean;
}

export type NativeNavigatorSplitRules = Array<{
  navigatorWidthRange: [
    number /* range start */,
    number? /* range end */
  ] /* compute range rules */;
  primarySceneWidth: number /* computed primary scene width */;
}>;

export interface NavigationNativeRouterConfig {
  headerMode?: NativeNavigatorHeaderModes;
  splitRules?: NativeNavigatorSplitRules;
  splitPlaceholder?: ComponentType<NavigationInjectedProps>;
  mode?: NativeNavigatorModes;
  initialRouteName?: string;
  defaultNavigationOptions?: NavigationScreenConfig<
    NativeNavigationOptions,
    any
  >;
}

export enum NativeNavigationStatusBarStyle {
  Default = 'default',
  DarkContent = 'darkContent',
  LightContent = 'lightContent'
}

export enum NativeNavigatorTransitions {
  Default = 'default',
  None = 'none',
  SlideFromTop = 'slideFromTop',
  SlideFromRight = 'slideFromRight',
  SlideFromBottom = 'slideFromBottom',
  SlideFromLeft = 'slideFromLeft'
}

export enum NativeNavigatorModes {
  Stack = 'stack',
  Card = 'card', // add child controller，默认不透明
  Split = 'split' // 分屏
}

export enum NativeNavigatorHeaderModes {
  None = 'none',
  Auto = 'auto'
}

export type NativeNavigationDescriptor = NavigationDescriptor<
  NavigationParams,
  NativeNavigationOptions
>;

export interface NativeNavigationDescriptorMap {
  [key: string]: NativeNavigationDescriptor;
}

export interface NativeNavigatorsProps extends NavigationInjectedProps {
  navigationConfig: NavigationNativeRouterConfig;
  screenProps?: any;
  descriptors: NativeNavigationDescriptorMap;
}

export enum NativeNavigationHeaderTypes {
  Center = 'center',
  Left = 'left',
  Right = 'right'
}

export interface NativeNavigatorSize {
  width: number;
  height: number;
}

export interface NativeNavigatorRect {
  x: number;
  y: number;
  width: number;
  height: number;
}

export enum NativeNavigatorDirection {
  Up = 'up',
  Down = 'down',
  Left = 'left',
  Right = 'right'
}
