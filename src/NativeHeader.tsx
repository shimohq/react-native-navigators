import React from 'react';
import { NavigationRoute } from 'react-navigation';

import {
  NativeNavigationDescriptor,
  NativeNavigationHeaderTypes
} from './types';
import NativeStackHeader from './NativeStackHeader';
import NativeStackHeaderItem from './NativeStackHeaderItem';

export interface NativeStackHeaderProps {
  descriptor: NativeNavigationDescriptor;
  route: NavigationRoute;
}

export default function NativeHeader(props: NativeStackHeaderProps) {
  const { route, descriptor } = props;
  const { key } = route;
  const {
    headerCenter,
    headerLeft,
    headerRight,
    headerBackgroundColor,
    headerBorderColor
  } = descriptor.options;

  return (
    <NativeStackHeader
      key={key}
      headerBackgroundColor={headerBackgroundColor}
      headerBorderColor={headerBorderColor}
    >
      {headerCenter ? (
        <NativeStackHeaderItem type={NativeNavigationHeaderTypes.Center}>
          {headerCenter}
        </NativeStackHeaderItem>
      ) : null}
      {headerLeft ? (
        <NativeStackHeaderItem type={NativeNavigationHeaderTypes.Left}>
          {headerLeft}
        </NativeStackHeaderItem>
      ) : null}
      {headerRight ? (
        <NativeStackHeaderItem type={NativeNavigationHeaderTypes.Right}>
          {headerRight}
        </NativeStackHeaderItem>
      ) : null}
    </NativeStackHeader>
  );
}
