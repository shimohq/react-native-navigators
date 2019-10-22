import { ReactNode } from 'react';
import { StyleProp, ViewStyle, TextStyle } from 'react-native';
import {
  NavigationParams,
  NavigationDescriptor,
  NavigationInjectedProps,
  NavigationScreenConfig
} from 'react-navigation';

export interface NativeNavigationPopover {
  directions?: number[];
}

export interface NativeNavigationOptions {
  transition?: NativeNavigatorTransitions;
  translucent?: boolean;
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

export enum NativeNavigatorTransitions {
  None = 'none',
  SlideFromTop = 'slideFromTop',
  SlideFromRight = 'slideFromRight',
  SlideFromBottom = 'slideFromBottom',
  SlideFromLeft = 'slideFromLeft'
}

export enum NativeNavigatorModes {
  Stack = 'stack',
  Modal = 'modal', // modal 为背景透明的界面
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
