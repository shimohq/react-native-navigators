export * from 'react-navigation';
import {
  NavigationStackAction as OriginalNavigationStackAction,
  NavigationAction as OriginalNavigationAction
} from 'react-navigation';

import { NavigationRemoveAction } from './StackActions';

export type NavigationStackAction =
  | OriginalNavigationStackAction
  | NavigationRemoveAction;

export type NavigationAction =
  | OriginalNavigationAction
  | NavigationRemoveAction;

import StackActions from './StackActions';
export * from './StackActions';
export { StackActions };
