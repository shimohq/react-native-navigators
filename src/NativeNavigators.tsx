import React, { PureComponent } from 'react';
import { NavigationRoute, StackActions } from 'react-navigation';

import {
  NativeNavigatorsProps,
  NativeNavigationDescriptorMap,
  NativeNavigatorTransitions,
  NativeNavigatorModes
} from './types';
import NativeStackNavigator from './NativeStackNavigator';
import NativeScenes from './NativeScenes';

interface NativeStackScenesState {
  // Local copy of the routes which are actually rendered
  routes: NavigationRoute[];
  // Previous routes, to compare whether routes have changed or not
  previousRoutes: NavigationRoute[];
  // List of routes being opened, we need to animate pushing of these new routes
  openingRouteKeys: string[];
  // List of routes being closed, we need to animate popping of these routes
  closingRouteKeys: string[];
  // List of routes being replaced, we need to keep a copy until the new route animates in
  replacingRouteKeys: string[];
  // Since the local routes can vary from the routes from props, we need to keep the descriptors for old routes
  // Otherwise we won't be able to access the options for routes that were removed
  descriptors: NativeNavigationDescriptorMap;
}

export default class NativeNavigators extends PureComponent<
  NativeNavigatorsProps,
  NativeStackScenesState
> {
  public static getDerivedStateFromProps(
    props: Readonly<NativeNavigatorsProps>,
    state: Readonly<NativeStackScenesState>
  ): NativeStackScenesState | null {
    // Here we determine which routes were added or removed to animate them
    // We keep a copy of the route being removed in local state to be able to animate it

    const { navigation } = props;

    // If there was no change in routes, we don't need to compute anything
    if (
      navigation.state.routes === state.previousRoutes &&
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

    if (navigation.state.index < navigation.state.routes.length - 1) {
      console.warn(
        'StackRouter provided invalid state, index should always be the last route in the stack.'
      );
    }

    // Now we need to determine which routes were added and removed
    let { openingRouteKeys, closingRouteKeys, replacingRouteKeys } = state;
    const { previousRoutes } = state;

    const previousFocusedRoute = previousRoutes[previousRoutes.length - 1] as
      | NavigationRoute
      | undefined;
    const nextFocusedRoute = routes[routes.length - 1];

    if (
      previousFocusedRoute &&
      previousFocusedRoute.key !== nextFocusedRoute.key
    ) {
      // We only need to animate routes if the focused route changed
      // Animating previous routes won't be visible coz the focused route is on top of everything

      const isAnimationEnabled = (route: NavigationRoute) => {
        const descriptor =
          props.descriptors[route.key] || state.descriptors[route.key];
        return descriptor
          ? descriptor.options.transition !== NativeNavigatorTransitions.None
          : true;
      };

      if (!previousRoutes.find(r => r.key === nextFocusedRoute.key)) {
        // A new route has come to the focus, we treat this as a push
        // A replace can also trigger this, the animation should look like push

        if (
          isAnimationEnabled(nextFocusedRoute) &&
          !openingRouteKeys.includes(nextFocusedRoute.key)
        ) {
          // In this case, we need to animate pushing the focused route
          // We don't care about animating any other added routes because they won't be visible
          openingRouteKeys = [...openingRouteKeys, nextFocusedRoute.key];

          closingRouteKeys = closingRouteKeys.filter(
            key => key !== nextFocusedRoute.key
          );
          replacingRouteKeys = replacingRouteKeys.filter(
            key => key !== nextFocusedRoute.key
          );

          if (!routes.find(r => r.key === previousFocusedRoute.key)) {
            // The previous focused route isn't present in state, we treat this as a replace

            replacingRouteKeys = [
              ...replacingRouteKeys,
              previousFocusedRoute.key
            ];

            openingRouteKeys = openingRouteKeys.filter(
              key => key !== previousFocusedRoute.key
            );
            closingRouteKeys = closingRouteKeys.filter(
              key => key !== previousFocusedRoute.key
            );

            // Keep the old route in state because it's visible under the new route, and removing it will feel abrupt
            // We need to insert it just before the focused one (the route being pushed)
            // After the push animation is completed, routes being replaced will be removed completely
            routes = routes.slice();
            routes.splice(routes.length - 1, 0, previousFocusedRoute);
          }
        }
      } else if (!routes.find(r => r.key === previousFocusedRoute.key)) {
        // The previously focused route was removed, we treat this as a pop

        if (
          isAnimationEnabled(previousFocusedRoute) &&
          !closingRouteKeys.includes(previousFocusedRoute.key)
        ) {
          // Sometimes a route can be closed before the opening animation finishes
          // So we also need to remove it from the opening list
          closingRouteKeys = [...closingRouteKeys, previousFocusedRoute.key];

          openingRouteKeys = openingRouteKeys.filter(
            key => key !== previousFocusedRoute.key
          );
          replacingRouteKeys = replacingRouteKeys.filter(
            key => key !== previousFocusedRoute.key
          );

          // Keep a copy of route being removed in the state to be able to animate it
          routes = [...routes, previousFocusedRoute];
        }
      } else {
        // Looks like some routes were re-arranged and no focused routes were added/removed
        // i.e. the currently focused route already existed and the previously focused route still exists
        // We don't know how to animate this
      }
    } else if (replacingRouteKeys.length || closingRouteKeys.length) {
      // Keep the routes we are closing or replacing
      routes = routes.slice();
      routes.splice(
        routes.length - 1,
        0,
        ...state.routes.filter(
          ({ key }) =>
            replacingRouteKeys.includes(key) || closingRouteKeys.includes(key)
        )
      );
    }

    if (!routes.length) {
      throw new Error(`There should always be at least one route.`);
    }

    const descriptors: NativeNavigationDescriptorMap = routes.reduce<
      NativeNavigationDescriptorMap
    >((acc, route) => {
      acc[route.key] =
        props.descriptors[route.key] || state.descriptors[route.key];

      return acc;
    }, {});

    return {
      routes,
      previousRoutes: navigation.state.routes,
      openingRouteKeys,
      closingRouteKeys,
      replacingRouteKeys,
      descriptors
    };
  }

  public state: NativeStackScenesState = {
    routes: [],
    previousRoutes: [],
    openingRouteKeys: [],
    closingRouteKeys: [],
    replacingRouteKeys: [],
    descriptors: {}
  };

  private handleOpenRoute = (route: NavigationRoute) => {
    this.handleTransitionComplete(route);
    this.setState(state => ({
      routes: state.replacingRouteKeys.length
        ? state.routes.filter(r => !state.replacingRouteKeys.includes(r.key))
        : state.routes,
      openingRouteKeys: state.openingRouteKeys.filter(key => key !== route.key),
      replacingRouteKeys: [],
      closingRouteKeys: state.closingRouteKeys.filter(key => key !== route.key)
    }));
  };

  private handleCloseRoute = (route: NavigationRoute) => {
    const index = this.state.routes.findIndex(r => r.key === route.key);
    // While closing route we need to point to the previous one assuming that
    // this previous one in routes array
    this.handleTransitionComplete(this.state.routes[Math.max(index - 1, 0)]);

    // This event will trigger when the animation for closing the route ends
    // In this case, we need to clean up any state tracking the route and pop it immediately

    // @ts-ignore
    this.setState(state => ({
      routes: state.routes.filter(r => r.key !== route.key),
      openingRouteKeys: state.openingRouteKeys.filter(key => key !== route.key),
      closingRouteKeys: state.closingRouteKeys.filter(key => key !== route.key)
    }));
  };

  private handleTransitionComplete = (route: NavigationRoute) => {
    if (this.props.navigation.state.isTransitioning) {
      this.props.navigation.dispatch(
        StackActions.completeTransition({ toChildKey: route.key })
      );
    }
  };

  private handleDismissRoute = (route: NavigationRoute) => {
    this.setState(
      state => ({
        routes: state.routes.filter(r => r.key !== route.key),
        openingRouteKeys: state.openingRouteKeys.filter(
          key => key !== route.key
        ),
        closingRouteKeys: state.closingRouteKeys.filter(
          key => key !== route.key
        )
      }),
      () => {
        this.props.navigation.goBack(route.key);
      }
    );
  };

  public render() {
    const { navigation, navigationConfig, screenProps } = this.props;

    const {
      routes,
      descriptors,
      openingRouteKeys,
      closingRouteKeys
    } = this.state;

    const mode: NativeNavigatorModes =
      navigationConfig.mode || NativeNavigatorModes.Modal;

    return (
      <NativeStackNavigator mode={mode}>
        <NativeScenes
          mode={mode}
          headerMode={navigationConfig.headerMode}
          routes={routes}
          descriptors={descriptors}
          openingRouteKeys={openingRouteKeys}
          closingRouteKeys={closingRouteKeys}
          navigation={navigation}
          screenProps={screenProps}
          onOpenRoute={this.handleOpenRoute}
          onCloseRoute={this.handleCloseRoute}
          onDismissRoute={this.handleDismissRoute}
        />
      </NativeStackNavigator>
    );
  }
}
