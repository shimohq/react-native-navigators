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
  closingRoutes: { [key: string]: boolean };
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

    // Remove any extra routes from the state
    // The last visible route should be the focused route, i.e. at current index
    const propRoutes = navigation.state.routes.slice(
      0,
      navigation.state.index + 1
    );

    const propRouteKeys: Set<string> = new Set(
      propRoutes.map(route => route.key)
    );

    const stateRoutes = state.routes;

    const closingRoutes: { [key: string]: boolean } = {};

    // 基于 prop routes 生成新的 routes 拷贝
    // 该拷贝会包含当前 prop routes 和 closing routes，并交给 native 进行渲染和执行动画
    const routes = propRoutes.slice();

    for (let index = 0; index < stateRoutes.length; index++) {
      const route = stateRoutes[index];
      const { key } = route;

      if (!propRouteKeys.has(key)) {
        if (index > 0) {
          // 获取在当前 route 前面的 route: routeBeforeIt
          const routeBeforeIt = stateRoutes[index - 1];

          // 将当前 route 在新数组中插入到 routeBeforeIt 后面
          // 由于插入算法保证了 stateRoutes 前面遍历的 route 一定在 routes 中，所以 routeBeforeIt 一定可在 routes 里面找到.
          const insertIndex =
            routes.findIndex(r => r.key === routeBeforeIt.key) + 1;
          routes.splice(insertIndex, 0, route);
        } else {
          routes.unshift(route);
        }

        // 当前 route 不在 propRouteKeys 中，表示当前 route 需要标记 closing ，交给 native 执行动画
        // 当 native 动画完成后回调 onDidBlur 并标记 dismissed: true 通知组件删除 closing 完成的路由
        closingRoutes[key] = true;
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
      closingRoutes,
      routes,
      propRoutes,
      screenProps
    };
  }

  public state: NativeStackScenesState = {
    propRoutes: [],
    routes: [],
    closingRoutes: {},
    descriptors: {},
    screenProps: undefined
  };

  private handleOpenRoute = () => {
    this.handleTransitionComplete();
  };

  private handleCloseRoute = (route: NavigationRoute) => {
    this.handleTransitionComplete();
    let { closingRoutes } = this.state;

    if (closingRoutes[route.key]) {
      closingRoutes = {
        ...closingRoutes,
        [route.key]: false
      };
    }

    this.setState({
      closingRoutes,
      routes: this.state.routes.filter(r => r.key !== route.key)
    });
  };

  private handleTransitionComplete = () => {
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
    const { closingRoutes, routes, descriptors, screenProps } = this.state;

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
        closingRoutes={closingRoutes}
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
                closingRoutes={closingRoutes}
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
