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
import NativeScenes from './NativeScenes';

interface NativeStackScenesState {
  propRoutes: NavigationRoute[];
  routes: NavigationRoute[];
  closingRouteKey: string | null;
  descriptors: NativeNavigationDescriptorMap;
}

export default class NativeNavigators extends PureComponent<
  NativeNavigatorsProps
> {
  public static getDerivedStateFromProps(
    props: Readonly<NativeNavigatorsProps>,
    state: Readonly<NativeStackScenesState>
  ): NativeStackScenesState | null {
    const { navigation } = props;

    if (navigation.state.routes === state.propRoutes && state.routes.length) {
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
      propRoutes: navigation.state.routes
    };
  }

  public state: NativeStackScenesState = {
    propRoutes: [],
    routes: [],
    closingRouteKey: null,
    descriptors: {}
  };

  private handleOpenRoute = (route: NavigationRoute) => {
    this.handleTransitionComplete(route);
  };

  private handleCloseRoute = (route: NavigationRoute) => {
    const { closingRouteKey } = this.state;
    this.setState({
      closingRouteKey: null,
      routes: this.state.routes.filter(route => route.key !== closingRouteKey)
    });
    this.handleTransitionComplete(route);
  };

  private handleTransitionComplete = (route: NavigationRoute) => {
    if (this.props.navigation.state.isTransitioning) {
      this.props.navigation.dispatch(
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
    const {
      navigation,
      navigationConfig,
      screenProps,
      descriptors
    } = this.props;
    const { closingRouteKey } = this.state;
    const mode: NativeNavigatorModes =
      navigationConfig.mode || NativeNavigatorModes.Modal;

    return (
      <NativeStackNavigator mode={mode}>
        <NativeScenes
          mode={mode}
          headerMode={navigationConfig.headerMode}
          routes={navigation.state.routes}
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
