import {
  StackRouter,
  NavigationRouter,
  NavigationRouteConfigMap,
  NavigationTabRouterConfig,
  NavigationActions,
  NavigationAction,
  NavigationState
} from 'react-navigation';

export default function SplitRouter(
  routeConfigs: NavigationRouteConfigMap<any, any>,
  config?: NavigationTabRouterConfig
): NavigationRouter {
  const stackRouter = StackRouter(routeConfigs, config);
  const { getStateForAction } = stackRouter;

  stackRouter.getStateForAction = (
    action: NavigationAction,
    state: NavigationState
  ) => {
    if (state) {
      if (action.type === NavigationActions.NAVIGATE) {
        const newState: NavigationState = getStateForAction(action, state);
        // StackRouter 对非 active 的子路由进行 NAVIGATE 操作时会主动将该子路由切换成 active
        // 如果在 SplitRouter 中对 primary route 的子路由做 NAVIGATE 导航会导致右侧路由退出，交互不符合预期
        if (newState.index === 0 && state.index > 0) {
          return {
            ...newState,
            index: state.index,
            routes: [...newState.routes, ...state.routes.slice(1)]
          };
        } else {
          return newState;
        }
      } else if (action.type === NavigationActions.BACK && action.key) {
        const newState: NavigationState = getStateForAction(action, state);
        // StackRouter 通过指定 key 的 action 对非 active 的子路由进行 BACK 导航时会将 active index 切换到该子路由
        // 如果 SplitRouter 中对 primary route 的子路由做 BACK 导航会导致右侧路由退出，交互不符合预期
        if (newState.index === 0 && newState.routes.length > 1) {
          return {
            ...newState,
            index: newState.routes.length - 1
          };
        } else {
          return newState;
        }
      }
    }

    return getStateForAction(action, state);
  };

  return stackRouter;
}
