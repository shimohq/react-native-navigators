import React, { ReactNode } from 'react';

export default function NativeStackSceneContainer(props: {
  children: ReactNode;
}) {
  return <>{props.children}</>;
}
