import React, {
  ReactElement,
  useState,
  createContext,
  useMemo,
  useCallback
} from 'react';

import NativeStackScenes, { NativeScenesProps } from './NativeScenes';
import { NativeNavigationSplitOptions } from './types';

export interface NativeSplitNavigatorOptionsWrapperProps {
  options?: NativeNavigationSplitOptions;
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
  const { children, options } = props;

  const [isSplitFullScreen, setIsSplitFullScreen] = useState(
    () => options?.isSplitFullScreen
  );
  const [splitLineColor, setSplitLineColor] = useState(() => options?.splitLineColor);
  const [splitRules, setSplitRules] = useState(() => options?.splitRules);
  const [splitPlaceholder, setSplitPlaceholder] = useState(
    () => options?.splitPlaceholder
  );
  const [splitPrimaryRouteNames, setSplitPrimaryRouteNames] = useState(
    () => options?.splitPrimaryRouteNames
  );

  const setOptions = useCallback(
    (options: Partial<NativeNavigationSplitOptions>) => {
      if (options.hasOwnProperty('isSplitFullScreen')) {
        setIsSplitFullScreen(options.isSplitFullScreen);
      }

      if (options.hasOwnProperty('splitLineColor')) {
        setSplitLineColor(options.splitLineColor);
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
    },
    []
  );

  const value = useMemo(() => {
    return {
      options: {
        isSplitFullScreen,
        splitLineColor,
        splitRules,
        splitPlaceholder,
        splitPrimaryRouteNames
      },
      setOptions
    };
  }, [isSplitFullScreen, splitLineColor, splitRules, splitPlaceholder, splitPrimaryRouteNames]);

  return (
    <NativeSplitNavigatorOptionsContext.Provider value={value}>
      {children(value.options)}
    </NativeSplitNavigatorOptionsContext.Provider>
  );
}
