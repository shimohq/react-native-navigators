import { StackActions as OriginalStackActions } from 'react-navigation';

export const REMOVE = 'Navigation/REMOVE';

export interface NavigationRemoveActionPayload {
  key: string;
}

export interface NavigationRemoveAction extends NavigationRemoveActionPayload {
  type: 'Navigation/REMOVE';
}

export const remove = (
  payload: NavigationRemoveActionPayload
): NavigationRemoveAction => ({
  type: REMOVE,
  key: payload.key
});

const StackActions = {
  ...OriginalStackActions,
  remove,
  REMOVE
};

export default StackActions;
