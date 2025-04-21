import React, { useRef, useEffect } from 'react';
import {
  requireNativeComponent,
  UIManager,
  findNodeHandle,
  Platform,
} from 'react-native';
import type { ViewStyle } from 'react-native';

const LINKING_ERROR = `The package 'react-native-dicom-viewer' doesn't seem to be linked.`;

type DicomViewerViewProps = {
  style?: ViewStyle;
  ref?: React.RefObject<any>;
};

const DicomViewerView =
  requireNativeComponent<DicomViewerViewProps>('DicomViewerView');

type Props = {
  style?: ViewStyle;
  path: string;
};

export default function DicomViewer({ style, path }: Props) {
  const ref = useRef(null);

  useEffect(() => {
    if (ref.current && Platform.OS === 'ios') {
      const nodeHandle = findNodeHandle(ref.current);
      if (nodeHandle !== null) {
        UIManager.dispatchViewManagerCommand(
          nodeHandle,
          UIManager.getViewManagerConfig('DicomViewerView').Commands.setPath,
          [path]
        );
      }
    }
  }, [path]);

  return <DicomViewerView style={style} ref={ref} />;
}
