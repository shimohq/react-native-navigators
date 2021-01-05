#!/bin/bash

while :
do
  CHANGED=$(watchman-wait ../ -p 'src/**/*' 'ios/**/*' 'android/**/*')
  echo "File: ${CHANGED} changed"
  if [[ $CHANGED = src* ]]
  then
    (cd .. && npm run build)
    cp -rf ../lib ./node_modules/react-native-navigators/
  else
    cp -f ../${CHANGED} ./node_modules/react-native-navigators/${CHANGED}
  fi
  
done
