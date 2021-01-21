import React, { memo, createContext } from 'react';
import { NavigationRoute, NavigationParams } from 'react-navigation';

import {
  NativeNavigationDescriptor,
  NativeNavigationOptions,
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
  descriptor: NativeNavigationDescriptor;
  route: NavigationRoute<NavigationParams>;
  screenProps?: unknown;
  mode: NativeNavigatorModes;
  headerMode?: NativeNavigatorHeaderModes;
  onDidFocus: (route: NavigationRoute) => void;
  onDidBlur: (route: NavigationRoute, dismissed: boolean) => void;
}

export const NativeNavigationDescriptorContext = createContext<{
  options: NativeNavigationOptions;
} | null>(null);

export default memo(function NativeScene(props: NativeSceneProps) {
  const {
    route,
    descriptor,
    closing,
    mode,
    screenProps,
    onDidFocus,
    onDidBlur
  } = props;
  const { key } = route;

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
          ? options.transition || NativeNavigatorTransitions.Default
          : NativeNavigatorTransitions.None
      }
      gestureEnabled={options.gestureEnabled !== false}
      translucent={options.translucent === true}
      transparent={options.transparent === true}
      splitFullScreen={options.splitFullScreen === true}
      style={options.cardStyle}
      statusBarStyle={options.statusBarStyle}
      statusBarHidden={options.statusBarHidden}
      closing={closing}
      onDidFocus={onDidFocus}
      onDidBlur={onDidBlur}
      route={route}
    >
      <NativeStackSceneContainer>
        <NativeSceneView
          screenProps={screenProps}
          navigation={navigation}
          component={descriptor.getComponent()}
        />
        {headerMode === NativeNavigatorHeaderModes.Auto ? (
          <NativeHeader options={options} route={route} />
        ) : null}
      </NativeStackSceneContainer>
    </NativeStackScene>
  );
});
