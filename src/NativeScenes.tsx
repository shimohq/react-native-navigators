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
  screenProps?: any;
  onTransitionComplete: (route: NavigationRoute) => void;
  onDismissRoute: (route: NavigationRoute) => void;
}

export default class NativeScenes extends PureComponent<NativeScenesProps> {
  private handleDidFocus = (route: NavigationRoute) => {
    this.props.onTransitionComplete(route);
  };

  private handleDidBlur = (route: NavigationRoute, dismissed: boolean) => {
    if (dismissed) {
      this.props.onDismissRoute(route);
    } else {
      this.props.onTransitionComplete(route);
    }
  };


  public render() {
    const {
      routes,
      descriptors,
      screenProps,
      mode
    } = this.props;

    return (
      <>
        {routes.map((route) => {
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
              transition={options.transition || NativeNavigatorTransitions.Default}
              gestureEnabled={options.gestureEnabled !== false}
              translucent={options.translucent === true}
              transparent={options.transparent === true}
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
