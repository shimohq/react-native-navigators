import React, { useContext, ComponentType } from 'react';
import {
  createNavigator,
  StackRouter,
  NavigationRouteConfigMap
} from 'react-navigation';
import StaticContainer from 'static-container';
import hoistNonReactStatics from 'hoist-non-react-statics';

import NativeNavigators from './NativeNavigators';
import SplitRouter from './SplitRouter';
import {
  NativeNavigationRouterConfig,
  NativeSplitNavigationRouterConfig,
  NativeNavigationOptions,
  NativeNavigatorModes
} from './types';
import { NativeNavigationClosingStateContext } from './NativeScene';

/**
 * Prevent Navigator updating while closing transition is performed.
 *
 * @param Navigator {ComponentType}
 * @returns {ComponentType}
 */
function preventNavigatorUpdateWhileClosing<Props>(
  Navigator: ComponentType<Props>
) {
  const ClosingUpdatePreventedNavigator = (props: Props) => {
    const closing = useContext(NativeNavigationClosingStateContext);

    return (
      <StaticContainer shouldUpdate={!closing}>
        <Navigator {...props} />
      </StaticContainer>
    );
  };

  return hoistNonReactStatics(ClosingUpdatePreventedNavigator, Navigator);
}

export function createNativeNavigator(
  routeConfigMap: NavigationRouteConfigMap<NativeNavigationOptions, any>,
  stackConfig: NativeNavigationRouterConfig
) {
  const router = StackRouter(routeConfigMap, stackConfig);
  return preventNavigatorUpdateWhileClosing(
    createNavigator(NativeNavigators, router, stackConfig)
  );
}

export function createStackNavigator(
  routeConfigMap: NavigationRouteConfigMap<NativeNavigationOptions, any>,
  stackConfig: Omit<NativeNavigationRouterConfig, 'mode'>
) {
  const router = StackRouter(routeConfigMap, stackConfig);
  return preventNavigatorUpdateWhileClosing(
    createNavigator(NativeNavigators, router, {
      ...stackConfig,
      mode: NativeNavigatorModes.Stack
    })
  );
}

export function createCardNavigator(
  routeConfigMap: NavigationRouteConfigMap<NativeNavigationOptions, any>,
  stackConfig: Omit<NativeNavigationRouterConfig, 'headerMode' | 'mode'>
) {
  const router = StackRouter(routeConfigMap, stackConfig);
  return preventNavigatorUpdateWhileClosing(
    createNavigator(NativeNavigators, router, {
      ...stackConfig,
      mode: NativeNavigatorModes.Card
    })
  );
}

export function createSplitNavigator(
  routeConfigMap: NavigationRouteConfigMap<NativeNavigationOptions, any>,
  splitConfig: Omit<NativeSplitNavigationRouterConfig, 'headerMode' | 'mode'>
) {
  const router = SplitRouter(routeConfigMap, splitConfig);
  return preventNavigatorUpdateWhileClosing(
    createNavigator(NativeNavigators, router, {
      ...splitConfig,
      mode: NativeNavigatorModes.Split
    })
  );
}
