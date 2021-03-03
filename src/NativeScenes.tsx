import React, { PureComponent } from 'react';
import { NavigationRoute, NavigationInjectedProps } from 'react-navigation';

import {
  NativeNavigationDescriptorMap,
  NativeNavigatorHeaderModes,
  NativeNavigatorModes
} from './types';
import NativeScene from './NativeScene';

export interface NativeScenesProps extends NavigationInjectedProps {
  routes: NavigationRoute[];
  mode: NativeNavigatorModes;
  headerMode?: NativeNavigatorHeaderModes;
  splitPrimaryRouteNames?: string[];
  descriptors: NativeNavigationDescriptorMap;
  screenProps?: unknown;
  onOpenRoute: (route: NavigationRoute) => void;
  onCloseRoute: (route: NavigationRoute) => void;
  onDismissRoute: (route: NavigationRoute) => void;
  closingRouteKey: string | null;
}

export default class NativeScenes extends PureComponent<NativeScenesProps> {
  private handleDidFocus = (route: NavigationRoute): void => {
    this.props.onOpenRoute(route);
  };

  private handleDidBlur = (route: NavigationRoute, dismissed: boolean) => {
    // If the scene has been removed from native side.
    if (dismissed) {
      if (this.props.closingRouteKey === route.key) {
        // Handle close transition complete.
        this.props.onCloseRoute(route);
      } else {
        // Handle dismiss from native side.
        this.props.onDismissRoute(route);
      }
    }
  };

  public render() {
    const {
      routes,
      descriptors,
      screenProps,
      mode,
      closingRouteKey,
      headerMode,
      splitPrimaryRouteNames
    } = this.props;

    const splitPrimaryRouteSet = new Set(splitPrimaryRouteNames);

    return (
      <>
        {routes.map(route => {
          const descriptor = descriptors[route.key];
          return (
            <NativeScene
              key={route.key}
              isSplitPrimary={splitPrimaryRouteSet.has(route.routeName)}
              closing={closingRouteKey === route.key}
              descriptor={descriptor}
              route={route}
              screenProps={screenProps}
              mode={mode}
              headerMode={headerMode}
              onDidFocus={this.handleDidFocus}
              onDidBlur={this.handleDidBlur}
            />
          );
        })}
      </>
    );
  }
}
