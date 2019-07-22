import React, { useEffect } from 'react';

import {
  EventEmitter,
  EVENT_NAVIGATION,
  KEY_SCENE_ID,
  KEY_ON,
  ON_COMPONENT_RESULT,
  ON_COMPONENT_DISAPPEAR,
  ON_COMPONENT_APPEAR,
  ON_DIALOG_BACK_PRESSED,
  KEY_REQUEST_CODE,
  KEY_RESULT_CODE,
  KEY_RESULT_DATA,
} from './NavigationModule';

export function useVisibleEffect(sceneId: string, fn: React.EffectCallback) {
  let onHidden: void | (() => void | undefined) = undefined;

  useEffect(() => {
    const subscription = EventEmitter.addListener(EVENT_NAVIGATION, data => {
      if (sceneId === data[KEY_SCENE_ID]) {
        if (data[KEY_ON] === ON_COMPONENT_APPEAR) {
          onHidden = fn();
        } else if (onHidden && data[KEY_ON] === ON_COMPONENT_DISAPPEAR) {
          onHidden();
        }
      }
    });

    return () => {
      subscription.remove();
    };
  }, [sceneId]);
}

export function useBackInterceptor(sceneId: string, fn: () => void) {
  useEffect(() => {
    const subscription = EventEmitter.addListener(EVENT_NAVIGATION, data => {
      if (sceneId === data[KEY_SCENE_ID] && data[KEY_ON] === ON_DIALOG_BACK_PRESSED) {
        fn();
      }
    });

    return () => {
      subscription.remove();
    };
  }, [sceneId]);
}

export function useResultData(
  sceneId: string,
  fn: (requestCode: number, resultCode: number, data: { [x: string]: any }) => void
) {
  useEffect(() => {
    const subscription = EventEmitter.addListener(EVENT_NAVIGATION, data => {
      if (sceneId === data[KEY_SCENE_ID] && data[KEY_ON] === ON_COMPONENT_RESULT) {
        fn(data[KEY_REQUEST_CODE], data[KEY_RESULT_CODE], data[KEY_RESULT_DATA]);
      }
    });

    return () => {
      subscription.remove();
    };
  }, [sceneId]);
}
