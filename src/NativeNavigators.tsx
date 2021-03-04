import React, { PureComponent } from 'react';
import {
  NavigationRoute,
  StackActions,
  NavigationActions
} from 'react-navigation';

import {
  NativeNavigatorsProps,
  NativeNavigationDescriptorMap,
  NativeNavigatorModes
} from './types';
import NativeStackNavigator from './NativeStackNavigator';
import NativeCardNavigator from './NativeCardNavigator';
import NativeSplitNavigator from './NativeSplitNavigator';
import NativeSplitNavigatorOptionsWrapper from './NativeSplitNavigatorOptionsWrapper';
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
    const { state } = navigation;
    if (state.isTransitioning) {
      navigation.dispatch(
        StackActions.completeTransition({
          toChildKey: state.routes[state.index]?.key
        })
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
    const scenes = (
      <NativeScenes
        mode={navigationConfig.mode}
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
    );

    if (navigationConfig.mode === NativeNavigatorModes.Split) {
      return (
        <NativeSplitNavigatorOptionsWrapper
          options={navigationConfig.defaultContextOptions}
        >
          {options => (
            <NativeSplitNavigator options={options}>
              <NativeScenes
                splitPrimaryRouteNames={options.splitPrimaryRouteNames}
                mode={navigationConfig.mode}
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
            </NativeSplitNavigator>
          )}
        </NativeSplitNavigatorOptionsWrapper>
      );
    } else if (navigationConfig.mode === NativeNavigatorModes.Card) {
      return <NativeCardNavigator>{scenes}</NativeCardNavigator>;
    } else {
      return <NativeStackNavigator>{scenes}</NativeStackNavigator>;
    }
  }
}
