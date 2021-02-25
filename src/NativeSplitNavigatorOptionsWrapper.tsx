import React, {
  ReactElement,
  useState,
  createContext,
  ElementType,
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
    options?.isSplitFullScreen
  );
  const [splitRules, setSplitRules] = useState(options?.splitRules);
  const [splitPlaceholder, setSplitPlaceholder] = useState<
    ElementType<{}> | undefined
  >(() => options?.splitPlaceholder);

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
    },
    []
  );

  const value = useMemo(() => {
    return {
      options: {
        isSplitFullScreen,
        splitRules,
        splitPlaceholder
      },
      setOptions
    };
  }, [isSplitFullScreen, splitRules, splitPlaceholder]);

  return (
    <NativeSplitNavigatorOptionsContext.Provider value={value}>
      {children(value.options)}
    </NativeSplitNavigatorOptionsContext.Provider>
  );
}
