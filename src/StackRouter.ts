import {
  StackRouter as OriginalStackRouter,
  NavigationRouter,
  NavigationRouteConfigMap,
  NavigationTabRouterConfig,
  NavigationState,
  NavigationRoute,
  NavigationAction
} from 'react-navigation';

import { NavigationRemoveAction, REMOVE } from './StackActions';
import { NativeNavigationRouterConfig } from './types';

function iterateRoutesState(
  state: NavigationRoute,
  routeHandler: (route: NavigationRoute) => NavigationRoute
): NavigationRoute {
  const { routes, index } = state;
  if (!routes) {
    return routeHandler(state);
  }

  for (let i = 0; i < routes.length; i++) {
    const route = routes[i];
    const newRoute = routeHandler(iterateRoutesState(route, routeHandler));

    if (newRoute !== route) {
      if (newRoute.routes.length > 0) {
        const newRoutes = routes.slice();
        newRoutes.splice(i, 1, newRoute);

        return {
          ...state,
          routes: newRoutes
        };
      } else {
        // 清除长度为 0 的子路由
        const newRoutes = routes.slice();
        newRoutes.splice(i, 1);

        return {
          ...state,
          index: index < i ? index : index - 1,
          routes: newRoutes,
          isTransitioning: true
        };
      }
    }
  }

  return state;
}

function removeNavigationReducer(
  action: NavigationRemoveAction,
  state: NavigationState | undefined
): NavigationState {
  const key: string = action.key;

  return iterateRoutesState(
    state as NavigationRoute,
    (route: NavigationRoute) => {
      const { routes, index } = route;
      const targetIndex = routes?.findIndex(r => r.key === key);

      if (!routes || targetIndex === -1) {
        return route;
      }

      // 删除 index === 0 的默认子路由等同于删除上级路由
      if (targetIndex === 0) {
        return {
          ...route,
          index: -1,
          routes: [],
          isTransitioning: true
        };
      } else {
        const newRoutes = route.routes.slice();
        newRoutes.splice(targetIndex, 1);

        return {
          ...route,
          index: index >= targetIndex ? index - 1 : index,
          routes: newRoutes,
          isTransitioning: true
        };
      }
    }
  );
}

export default function StackRouter(
  routeConfigs: NavigationRouteConfigMap<any, any>,
  config?: NavigationTabRouterConfig
): NavigationRouter<NavigationState, NativeNavigationRouterConfig> {
  const stackRouter = OriginalStackRouter(routeConfigs, config);
  const { getStateForAction } = stackRouter;

  stackRouter.getStateForAction = (
    action: NavigationAction | NavigationRemoveAction,
    state: NavigationState | undefined
  ): NavigationState | null => {
    if (action.type === REMOVE) {
      return removeNavigationReducer(action, state);
    }
    return getStateForAction(action, state);
  };

  return stackRouter;
}
