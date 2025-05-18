import React from 'react';
import { StyleSheet, Image, ImageProps, ImageResizeMode } from 'react-native';
import FastImage from 'react-native-fast-image';

// @ts-ignore
Image.render = function (props: ImageProps, ref: React.RefObject<Image>) {
  const { style, source, resizeMode, ..._props } = props;
  let _style = StyleSheet.flatten(style) || {};

  if (typeof source === 'number') {
    const { width, height } = Image.resolveAssetSource(source);
    if (width && height) {
      _style = { width, height, ..._style };
    }
  }

  return React.createElement<any>(FastImage, {
    ..._props,
    style: { ..._style },
    source,
    resizeMode: fastImageResizeMode(resizeMode),
    tintColor: _style.tintColor,
    ref,
  });
};

function fastImageResizeMode(mode: ImageResizeMode = 'cover') {
  switch (mode) {
    case 'contain':
      return FastImage.resizeMode.contain;
    case 'stretch':
      return FastImage.resizeMode.stretch;
    case 'center':
      return FastImage.resizeMode.center;
    case 'cover':
      return FastImage.resizeMode.cover;
    case 'repeat':
      return FastImage.resizeMode.cover;
  }
}
