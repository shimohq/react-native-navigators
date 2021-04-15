import {
  createNavigator,
  StackRouter,
  NavigationRouteConfigMap
} from 'react-navigation';

import NativeNavigators from './NativeNavigators';
import SplitRouter from './SplitRouter';
import {
  NativeNavigationRouterConfig,
  NativeSplitNavigationRouterConfig,
  NativeNavigationOptions,
  NativeNavigatorModes,
  NativeNavigator
} from './types';

export function createNativeNavigator(
  routeConfigMap: NavigationRouteConfigMap<NativeNavigationOptions, any>,
  stackConfig: NativeNavigationRouterConfig
): NativeNavigator {
  const router = StackRouter(routeConfigMap, stackConfig);
  return createNavigator(NativeNavigators, router, stackConfig);
}

export function createStackNavigator(
  routeConfigMap: NavigationRouteConfigMap<NativeNavigationOptions, any>,
  stackConfig: Omit<NativeNavigationRouterConfig, 'mode'>
): NativeNavigator {
  const router = StackRouter(routeConfigMap, stackConfig);
  return createNavigator(NativeNavigators, router, {
    ...stackConfig,
    mode: NativeNavigatorModes.Stack
  });
}

export function createCardNavigator(
  routeConfigMap: NavigationRouteConfigMap<NativeNavigationOptions, any>,
  stackConfig: Omit<NativeNavigationRouterConfig, 'headerMode' | 'mode'>
): NativeNavigator {
  const router = StackRouter(routeConfigMap, stackConfig);
  return createNavigator(NativeNavigators, router, {
    ...stackConfig,
    mode: NativeNavigatorModes.Card
  });
}

export function createSplitNavigator(
  routeConfigMap: NavigationRouteConfigMap<NativeNavigationOptions, any>,
  splitConfig: Omit<NativeSplitNavigationRouterConfig, 'headerMode' | 'mode'>
): NativeNavigator {
  const router = SplitRouter(routeConfigMap, splitConfig);
  return createNavigator(NativeNavigators, router, {
    ...splitConfig,
    mode: NativeNavigatorModes.Split
  });
}
