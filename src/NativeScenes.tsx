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
  private handleDidFocus = (route: NavigationRoute) => {
    this.props.onOpenRoute(route);
  }

  private handleDidBlur = (route: NavigationRoute, dismissed: boolean) => {
    if (dismissed) {
      this.props.onDismissRoute(route);
    } else if (this.isClosing(route.key)) {
      this.props.onCloseRoute(route);
    }
  }

  private isClosing = (key: string) => {
    const {
      closingRouteKeys,
      replacingRouteKeys,
    } = this.props;
    return closingRouteKeys.includes(key) || replacingRouteKeys.includes(key)
  };

  public render() {
    const {
      routes,
      descriptors,
      screenProps,
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
              closing={this.isClosing(key)}
              popover={options.popover}
              onDidFocus={this.handleDidFocus}
              onDidBlur={this.handleDidBlur}
              route={route}
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
