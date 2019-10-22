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
  openingRouteKeys: string[];
  closingRouteKeys: string[];
  screenProps?: any;
  onOpenRoute: (route: NavigationRoute) => void;
  onCloseRoute: (route: NavigationRoute) => void;
  onDismissRoute: (route: NavigationRoute) => void;
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
      openingRouteKeys,
      screenProps,
      onDismissRoute,
      mode
    } = this.props;

    return (
      <>
        {routes.map((route, index) => {
          const { key } = route;
          const descriptor = descriptors[key];
          const { options, navigation } = descriptor;
          const closing = closingRouteKeys.includes(key);

          let transition = NativeNavigatorTransitions.None;

          // 转场动画由最后一个 route 决定
          if (routes.length - 1 === index) {
            if (openingRouteKeys.includes(key) || closing) {
              transition =
                options.transition || NativeNavigatorTransitions.SlideFromRight;
            }
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
              closing={closing}
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
