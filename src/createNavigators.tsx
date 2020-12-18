import {
  createNavigator,
  StackRouter,
  NavigationRouteConfigMap
} from 'react-navigation';

import NativeNavigators from './NativeNavigators';
import {
  NavigationNativeRouterConfig,
  NativeNavigationOptions,
  NativeNavigatorModes
} from './types';

export function createNativeNavigator(
  routeConfigMap: NavigationRouteConfigMap<NativeNavigationOptions, any>,
  stackConfig: NavigationNativeRouterConfig
) {
  const router = StackRouter(routeConfigMap, stackConfig);
  return createNavigator(NativeNavigators, router, stackConfig);
}

export function createStackNavigator(
  routeConfigMap: NavigationRouteConfigMap<NativeNavigationOptions, any>,
  stackConfig: Omit<NavigationNativeRouterConfig, 'mode'>
) {
  const router = StackRouter(routeConfigMap, stackConfig);
  return createNavigator(NativeNavigators, router, {
    ...stackConfig,
    mode: NativeNavigatorModes.Stack
  });
}

export function createCardNavigator(
  routeConfigMap: NavigationRouteConfigMap<NativeNavigationOptions, any>,
  stackConfig: Omit<NavigationNativeRouterConfig, 'headerMode' | 'mode'>
) {
  const router = StackRouter(routeConfigMap, stackConfig);
  return createNavigator(NativeNavigators, router, {
    ...stackConfig,
    mode: NativeNavigatorModes.Card
  });
}

export function createSplitNavigator(
  routeConfigMap: NavigationRouteConfigMap<NativeNavigationOptions, any>,
  stackConfig: Omit<NavigationNativeRouterConfig, 'headerMode' | 'mode'>
) {
  const router = StackRouter(routeConfigMap, stackConfig);
  return createNavigator(NativeNavigators, router, {
    ...stackConfig,
    mode: NativeNavigatorModes.Split
  });
}
