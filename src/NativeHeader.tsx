import React from 'react';
import { Text, StyleSheet, Platform } from 'react-native';
import { NavigationRoute } from 'react-navigation';

import { NativeNavigationHeaderTypes, NativeNavigationOptions } from './types';
import NativeStackHeader from './NativeStackHeader';
import NativeStackHeaderItem from './NativeStackHeaderItem';

export interface NativeStackHeaderProps {
  options: NativeNavigationOptions;
  route: NavigationRoute;
}

const styles = StyleSheet.create({
  title: {
    fontSize: Platform.OS === 'ios' ? 17 : 20,
    fontWeight: Platform.OS === 'ios' ? '600' : '500',
    color: 'rgba(0, 0, 0, .9)',
    marginHorizontal: 16
  }
});

export default function NativeHeader(props: NativeStackHeaderProps) {
  const { route, options } = props;
  const { key } = route;
  const {
    headerCenter,
    headerLeft,
    headerRight,
    headerBackgroundColor,
    headerBorderColor,
    headerTitle,
    headerTitleStyle
  } = options;

  const center = headerCenter ? (
    headerCenter
  ) : headerTitle ? (
    <Text style={[styles.title, headerTitleStyle]} numberOfLines={1}>
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
