import {
  requireNativeComponent,
  UIManager,
  type ViewProps,
} from 'react-native';

type DicomViewerProps = ViewProps & {
  src?: string;
  onFrameChange?: (event: {
    nativeEvent: { index: number; total: number };
  }) => void;
};

const DicomViewer =
  UIManager.getViewManagerConfig('DicomViewerView') != null
    ? requireNativeComponent<DicomViewerProps>('DicomViewerView')
    : () => null;

export default DicomViewer;
