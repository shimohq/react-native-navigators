import { ReactNode } from 'react';
import { StyleProp, ViewStyle, TextStyle } from 'react-native';
import {
  NavigationParams,
  NavigationDescriptor,
  NavigationInjectedProps,
  NavigationScreenConfig
} from 'react-navigation';

export interface NativeNavigationPopover {
  sourceViewNativeID: string;
  contentSize: NativeNavigatorSize;
  sourceRect?: NativeNavigatorRect;
  directions?: NativeNavigatorDirection[];
}

export interface NativeNavigationOptions {
  transition?: NativeNavigatorTransitions;
  translucent?: boolean;
  transparent?: boolean;
  cardStyle?: StyleProp<ViewStyle>;
  gestureEnabled?: boolean;
  headerLeft?: ReactNode;
  headerCenter?: ReactNode;
  headerRight?: ReactNode;
  headerBackgroundColor?: string;
  headerBorderColor?: string;
  headerHidden?: boolean;
  headerTitle?: string;
  headerTitleStyle?: StyleProp<TextStyle>;
  popover?: NativeNavigationPopover;
  statusBarStyle?: NativeNavigationStatusBarStyle;
  statusBarHidden?: boolean;
}

export interface NavigationNativeRouterConfig {
  headerMode?: NativeNavigatorHeaderModes;
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
  Split = 'split' // todo
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
