import React, {
  ReactElement,
  useState,
  createContext,
  useMemo,
  useCallback,
  useEffect
} from 'react';
import { NavigationInjectedProps } from 'react-navigation';

import NativeStackScenes, { NativeScenesProps } from './NativeScenes';
import {
  NativeNavigationSplitOptions,
  NativeNavigationSplitConfig
} from './types';

export interface NativeSplitNavigatorOptionsWrapperProps
  extends NavigationInjectedProps {
  options?: NativeNavigationSplitConfig;
  screenProps: unknown;
  children: (
    options: NativeNavigationSplitOptions
  ) => ReactElement<NativeScenesProps, typeof NativeStackScenes>;
}

export const NativeSplitNavigatorOptionsContext = createContext<{
  options: NativeNavigationSplitOptions;
  setOptions: (options: Partial<NativeNavigationSplitOptions>) => void;
}>({ options: {}, setOptions: () => {} });

export default function NativeSplitNavigatorOptionsWrapper(
  props: NativeSplitNavigatorOptionsWrapperProps
) {
  const { children, navigation, screenProps } = props;
  const options =
    typeof props.options === 'function'
      ? props.options({
          navigation,
          screenProps
        })
      : props.options;

  const [isSplitFullScreen, setIsSplitFullScreen] = useState(
    () => options?.isSplitFullScreen
  );

  useEffect(() => {
    if (options?.isSplitFullScreen !== isSplitFullScreen) {
      setIsSplitFullScreen(options?.isSplitFullScreen);
    }
  }, [options?.isSplitFullScreen]);

  const [splitRules, setSplitRules] = useState(() => options?.splitRules);

  useEffect(() => {
    if (options?.splitRules !== splitRules) {
      setSplitRules(options?.splitRules);
    }
  }, [options?.splitRules]);

  const [splitPlaceholder, setSplitPlaceholder] = useState(
    () => options?.splitPlaceholder
  );

  useEffect(() => {
    if (options?.splitPlaceholder !== splitPlaceholder) {
      setSplitPlaceholder(options?.splitPlaceholder);
    }
  }, [options?.splitPlaceholder]);

  const [splitPrimaryRouteNames, setSplitPrimaryRouteNames] = useState(
    () => options?.splitPrimaryRouteNames
  );

  useEffect(() => {
    if (options?.splitPrimaryRouteNames !== splitPrimaryRouteNames) {
      setSplitPrimaryRouteNames(options?.splitPrimaryRouteNames);
    }
  }, [options?.splitPrimaryRouteNames]);

  const [splitLineColor, setSplitLineColor] = useState(
    () => options?.splitLineColor
  );

  useEffect(() => {
    if (options?.splitLineColor !== splitLineColor) {
      setSplitLineColor(options?.splitLineColor);
    }
  }, [options?.splitLineColor]);

  const setOptions = useCallback(
    (options: Partial<NativeNavigationSplitOptions>) => {
      if (options.hasOwnProperty('isSplitFullScreen')) {
        setIsSplitFullScreen(options.isSplitFullScreen);
      }

      if (options.hasOwnProperty('splitRules')) {
        setSplitRules(options.splitRules);
      }

      if (options.hasOwnProperty('splitPlaceholder')) {
        setSplitPlaceholder(options.splitPlaceholder);
      }

      if (options.hasOwnProperty('splitPrimaryRouteNames')) {
        setSplitPrimaryRouteNames(options.splitPrimaryRouteNames);
      }

      if (options.hasOwnProperty('splitLineColor')) {
        setSplitLineColor(options.splitLineColor);
      }
    },
    []
  );

  const value = useMemo(() => {
    return {
      options: {
        isSplitFullScreen,
        splitRules,
        splitPlaceholder,
        splitPrimaryRouteNames,
        splitLineColor
      },
      setOptions
    };
  }, [
    isSplitFullScreen,
    splitRules,
    splitPlaceholder,
    splitPrimaryRouteNames,
    splitLineColor
  ]);

  return (
    <NativeSplitNavigatorOptionsContext.Provider value={value}>
      {children(value.options)}
    </NativeSplitNavigatorOptionsContext.Provider>
  );
}
