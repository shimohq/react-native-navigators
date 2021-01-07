import React, { PureComponent, ComponentType } from 'react';
import {
  NavigationRoute,
  StackActions,
  NavigationActions,
  NavigationInjectedProps
} from 'react-navigation';

import {
  NativeNavigatorsProps,
  NativeNavigationDescriptorMap,
  NativeNavigatorModes,
  NativeNavigatorSplitRules
} from './types';
import NativeStackNavigator from './NativeStackNavigator';
import NativeScenes from './NativeScenes';

interface NativeStackScenesState {
  propRoutes: NavigationRoute[];
  routes: NavigationRoute[];
  closingRouteKey: string | null;
  descriptors: NativeNavigationDescriptorMap;
  screenProps: unknown;
}

export default class NativeNavigators extends PureComponent<
  NativeNavigatorsProps
> {
  public static getDerivedStateFromProps(
    props: Readonly<NativeNavigatorsProps>,
    state: Readonly<NativeStackScenesState>
  ): NativeStackScenesState | null {
    const { navigation, screenProps } = props;

    if (
      navigation.state.routes === state.propRoutes &&
      screenProps === state.screenProps &&
      state.routes.length
    ) {
      return null;
    }

    let routes =
      navigation.state.index < navigation.state.routes.length - 1
        ? // Remove any extra routes from the state
          // The last visible route should be the focused route, i.e. at current index
          navigation.state.routes.slice(0, navigation.state.index + 1)
        : navigation.state.routes;
    const routeKeys: string[] = routes.map(route => route.key);

    let { closingRouteKey } = state;
    const previousFocusedRoute = state.routes[state.routes.length - 1] as
      | NavigationRoute
      | undefined;
    const nextFocusedRoute = routes[routes.length - 1];

    if (closingRouteKey === previousFocusedRoute?.key) {
      // During a closing transition, just update the routes state.
      routes = [...routes, previousFocusedRoute];
    } else if (
      previousFocusedRoute &&
      previousFocusedRoute.key !== nextFocusedRoute.key
    ) {
      // Should perform a closing transition, and keep the topmost scene in the routes state.
      if (!routeKeys.includes(previousFocusedRoute.key as string)) {
        routes = [...routes, previousFocusedRoute];
        closingRouteKey = previousFocusedRoute.key;
      }
    }

    const descriptors: NativeNavigationDescriptorMap = routes.reduce<
      NativeNavigationDescriptorMap
    >((acc, route) => {
      acc[route.key] =
        props.descriptors[route.key] || state.descriptors[route.key];
      return acc;
    }, {});

    return {
      descriptors,
      closingRouteKey,
      routes,
      propRoutes: navigation.state.routes,
      screenProps
    };
  }

  public state: NativeStackScenesState = {
    propRoutes: [],
    routes: [],
    closingRouteKey: null,
    descriptors: {},
    screenProps: undefined
  };

  private handleOpenRoute = (route: NavigationRoute) => {
    this.handleTransitionComplete(route);
  };

  private handleCloseRoute = (route: NavigationRoute) => {
    this.handleTransitionComplete(route);

    this.setState({
      closingRouteKey: null,
      routes: this.state.routes.filter(r => r.key !== route.key)
    });
  };

  private handleTransitionComplete = (route: NavigationRoute) => {
    const { navigation } = this.props;

    if (navigation.state.isTransitioning) {
      navigation.dispatch(
        StackActions.completeTransition({ toChildKey: route.key })
      );
    }
  };

  private handleDismissRoute = (route: NavigationRoute) => {
    const { navigation } = this.props;
    const { routes, propRoutes } = this.state;

    this.setState({
      routes: routes.filter(r => r.key !== route.key),
      propRoutes: propRoutes.filter(r => r.key !== route.key)
    });

    navigation.dispatch({
      type: NavigationActions.BACK,
      key: route.key,
      immediate: true
    });
  };

  public render() {
    const { navigation, navigationConfig } = this.props;
    const { closingRouteKey, routes, descriptors, screenProps } = this.state;
    const mode: NativeNavigatorModes =
      navigationConfig.mode || NativeNavigatorModes.Stack;

    let splitRules: NativeNavigatorSplitRules | undefined =
      navigationConfig.splitRules;

    if (mode !== NativeNavigatorModes.Split && splitRules) {
      console.warn(
        `Navigation config \`splitRules\` is not supported for \`${mode}\` navigator.`
      );
      splitRules = undefined;
    } else if (mode === NativeNavigatorModes.Split && !splitRules) {
      console.error(
        `Navigation config \`splitRules\` is required for \`${mode}\` navigator.`
      );
    }

    let splitPlaceholder: ComponentType<NavigationInjectedProps> | undefined =
      navigationConfig.splitPlaceholder;
    if (mode !== NativeNavigatorModes.Split && splitPlaceholder) {
      console.warn(
        `Navigation config \`splitPlaceholder\` is not supported for \`${mode}\` navigator.`
      );
      splitRules = undefined;
    }

    return (
      <NativeStackNavigator
        mode={mode}
        navigation={navigation}
        splitRules={splitRules}
        splitPlaceholder={splitPlaceholder}
      >
        <NativeScenes
          mode={mode}
          headerMode={navigationConfig.headerMode}
          routes={routes}
          descriptors={descriptors}
          navigation={navigation}
          screenProps={screenProps}
          onOpenRoute={this.handleOpenRoute}
          onCloseRoute={this.handleCloseRoute}
          onDismissRoute={this.handleDismissRoute}
          closingRouteKey={closingRouteKey}
        />
      </NativeStackNavigator>
    );
  }
}
