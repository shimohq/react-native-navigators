import React, { PureComponent } from 'react';
import {
  NavigationRoute,
  NavigationInjectedProps
} from 'react-navigation';

import {
  NativeNavigationDescriptorMap,
  NativeNavigatorTransitions,
  NativeNavigatorHeaderModes,
  NativeNavigatorModes
} from './types';
import NativeSceneView from './NativeSceneView';
import NativeStackScene from './NativeStackScene';
import NativeHeader from './NativeHeader';
import NativeStackSceneContainer from './NativeStackSceneContainer';

export interface NativeScenesProps extends NavigationInjectedProps {
  routes: NavigationRoute[];
  mode: NativeNavigatorModes;
  headerMode?: NativeNavigatorHeaderModes;
  descriptors: NativeNavigationDescriptorMap;
  screenProps?: any;
  onOpenRoute: (route: NavigationRoute) => void;
  onCloseRoute: (route: NavigationRoute) => void;
  onDismissRoute: (route: NavigationRoute) => void;
  closingRouteKey: string | null;
}

export default class NativeScenes extends PureComponent<NativeScenesProps> {
  private handleDidFocus = (route: NavigationRoute) => {
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
    const { routes, descriptors, screenProps, mode, closingRouteKey } = this.props;

    return (
      <>
        {routes.map(route => {
          const { key } = route;
          const descriptor = descriptors[key];

          if (!descriptor) {
            return null;
          }

          const { options, navigation } = descriptor;

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
              transition={
                options.transition || NativeNavigatorTransitions.Default
              }
              closing={closingRouteKey === route.key}
              gestureEnabled={options.gestureEnabled !== false}
              translucent={options.translucent === true}
              transparent={options.transparent === true}
              popover={options.popover}
              onDidFocus={this.handleDidFocus}
              onDidBlur={this.handleDidBlur}
              route={route}
              style={options.cardStyle}
            >
              <NativeStackSceneContainer>
                <NativeSceneView
                  screenProps={screenProps}
                  navigation={navigation}
                  component={SceneComponent}
                />
                {headerMode === NativeNavigatorHeaderModes.Auto ? (
                  <NativeHeader descriptor={descriptor} route={route} />
                ) : null}
              </NativeStackSceneContainer>
            </NativeStackScene>
          );
        })}
      </>
    );
  }
}
