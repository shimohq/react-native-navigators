import React, { memo, createContext, useContext } from 'react';
import {
  NavigationRoute,
  NavigationParams,
  NavigationContext
} from 'react-navigation';

import {
  NativeNavigationDescriptor,
  NativeNavigatorTransitions,
  NativeNavigatorHeaderModes,
  NativeNavigatorModes
} from './types';
import NativeSceneView from './NativeSceneView';
import NativeStackScene from './NativeStackScene';
import NativeHeader from './NativeHeader';
import NativeStackSceneContainer from './NativeStackSceneContainer';

export interface NativeSceneProps {
  closing: boolean;
  isSplitPrimary: boolean;
  descriptor: NativeNavigationDescriptor;
  route: NavigationRoute<NavigationParams>;
  screenProps?: unknown;
  mode: NativeNavigatorModes;
  headerMode?: NativeNavigatorHeaderModes;
  onDidFocus: (route: NavigationRoute) => void;
  onDidBlur: (route: NavigationRoute, dismissed: boolean) => void;
}

// 'willBlur' event won't emit during the closing transition.
// NativeNavigationClosingStateContext is convenient for some cases when you want to get the closing state for a scene.
export const NativeNavigationClosingStateContext = createContext<boolean>(
  false
);

export default memo(function NativeScene(props: NativeSceneProps) {
  const {
    route,
    descriptor,
    closing,
    isSplitPrimary,
    mode,
    screenProps,
    onDidFocus,
    onDidBlur
  } = props;
  const { key } = route;

  const closingContextState = useContext(NativeNavigationClosingStateContext);

  if (!descriptor) {
    return null;
  }

  const { options, navigation } = descriptor;

  let headerMode = options.headerHidden
    ? NativeNavigatorHeaderModes.None
    : props.headerMode;

  if (mode === NativeNavigatorModes.Stack) {
    headerMode = headerMode ?? NativeNavigatorHeaderModes.Auto;
  } else if (mode === NativeNavigatorModes.Split) {
    headerMode = NativeNavigatorHeaderModes.None; // split navigator do not support native header
  } else {
    headerMode = headerMode ?? NativeNavigatorHeaderModes.None;
  }

  return (
    <NativeStackScene
      key={key}
      transition={
        navigation.dangerouslyGetParent()?.state?.isTransitioning
          ? options.transition ?? NativeNavigatorTransitions.Default
          : NativeNavigatorTransitions.None
      }
      isSplitPrimary={isSplitPrimary}
      gestureEnabled={options.gestureEnabled !== false}
      translucent={options.translucent === true}
      transparent={options.transparent === true}
      style={options.cardStyle}
      statusBarStyle={options.statusBarStyle}
      statusBarHidden={options.statusBarHidden}
      closing={closing}
      onDidFocus={onDidFocus}
      onDidBlur={onDidBlur}
      route={route}
    >
      <NativeStackSceneContainer>
        <NativeNavigationClosingStateContext.Provider
          value={closing || closingContextState}
        >
          <NativeSceneView
            screenProps={screenProps}
            navigation={navigation}
            component={descriptor.getComponent()}
          />
        </NativeNavigationClosingStateContext.Provider>
        {headerMode === NativeNavigatorHeaderModes.Auto ? (
          <NavigationContext.Provider value={navigation}>
            <NativeHeader options={options} route={route} />
          </NavigationContext.Provider>
        ) : null}
      </NativeStackSceneContainer>
    </NativeStackScene>
  );
});
