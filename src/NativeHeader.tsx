import React from 'react';
import { Text } from 'react-native';
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
    headerBorderColor,
    headerTitle,
    headerTitleStyle
  } = descriptor.options;

  const center = headerCenter ? (
    headerCenter
  ) : headerTitle ? (
    <Text style={headerTitleStyle} numberOfLines={1}>
      {headerTitle}
    </Text>
  ) : null;

  return (
    <NativeStackHeader
      key={key}
      headerBackgroundColor={headerBackgroundColor}
      headerBorderColor={headerBorderColor}
    >
      {center ? (
        <NativeStackHeaderItem type={NativeNavigationHeaderTypes.Center}>
          {center}
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
