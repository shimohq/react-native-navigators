export * from 'react-navigation';
import {
  NavigationStackAction as OriginalNavigationStackAction,
  NavigationAction as OriginalNavigationAction
} from 'react-navigation';

import {
  NavigationRemoveAction,
  NavigationRemoveActionPayload
} from './StackActions';

export type NavigationStackAction =
  | OriginalNavigationStackAction
  | NavigationRemoveAction;

export type NavigationAction =
  | OriginalNavigationAction
  | NavigationRemoveAction;

declare module 'react-navigation' {
  export namespace StackActions {
    export const REMOVE: 'Navigation/REMOVE';
    export function remove(
      payload: NavigationRemoveActionPayload
    ): NavigationRemoveAction;
  }
}

import * as StackActions from './StackActions';
export { StackActions };
