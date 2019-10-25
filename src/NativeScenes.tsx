import React, { PureComponent } from 'react';
import {
  NavigationRoute,
  NavigationInjectedProps,
  SceneView
} from 'react-navigation';

import {
  NativeNavigationDescriptorMap,
  NativeNavigatorTransitions,
  NativeNavigatorHeaderModes,
  NativeNavigatorModes
} from './types';
import NativeStackScene from './NativeStackScene';
import NativeHeader from './NativeHeader';

export interface NativeScenesProps extends NavigationInjectedProps {
  routes: NavigationRoute[];
  mode: NativeNavigatorModes;
  headerMode?: NativeNavigatorHeaderModes;
  descriptors: NativeNavigationDescriptorMap;
  closingRouteKeys: string[];
  replacingRouteKeys: string[];
  screenProps?: any;
  onOpenRoute: (route: NavigationRoute) => void;
  onCloseRoute: (route: NavigationRoute) => void;
  onDismissRoute: (route: NavigationRoute) => void;
  transitionEnabled: boolean;
}

export default class NativeScenes extends PureComponent<NativeScenesProps> {
  private handleTransitionEnd = (route: NavigationRoute, closing: boolean) => {
    if (closing) {
      this.props.onCloseRoute(route);
    } else {
      this.props.onOpenRoute(route);
    }
  };

  public render() {
    const {
      routes,
      descriptors,
      closingRouteKeys,
      replacingRouteKeys,
      screenProps,
      onDismissRoute,
      mode,
      transitionEnabled
    } = this.props;

    return (
      <>
        {routes.map((route, index) => {
          const { key } = route;
          const descriptor = descriptors[key];
          const { options, navigation } = descriptor;

          let transition = NativeNavigatorTransitions.None;

          if (transitionEnabled && routes.length - 1 === index) {
            transition =
              options.transition || NativeNavigatorTransitions.Default;
          }

          let headerMode = options.headerHidden
            ? NativeNavigatorHeaderModes.None
            : this.props.headerMode;

          if (mode === NativeNavigatorModes.Stack) {
            headerMode = headerMode || NativeNavigatorHeaderModes.Auto;
          } else {
            headerMode = headerMode || NativeNavigatorHeaderModes.None;
          }

          const SceneComponent = descriptor.getComponent();

          return (
            <NativeStackScene
              key={key}
              transition={transition}
              gestureEnabled={options.gestureEnabled !== false}
              translucent={options.translucent === true}
              transparent={options.transparent === true}
              closing={
                closingRouteKeys.includes(key) ||
                replacingRouteKeys.includes(key)
              }
              popover={options.popover}
              onTransitionEnd={this.handleTransitionEnd}
              route={route}
              onDismissed={onDismissRoute}
              style={options.cardStyle}
            >
              <SceneView
                screenProps={screenProps}
                navigation={navigation}
                component={SceneComponent}
              />
              {headerMode === NativeNavigatorHeaderModes.Auto ? (
                <NativeHeader descriptor={descriptor} route={route} />
              ) : null}
            </NativeStackScene>
          );
        })}
      </>
    );
  }
}
