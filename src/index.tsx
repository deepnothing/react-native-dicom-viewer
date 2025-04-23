import {
  requireNativeComponent,
  UIManager,
  type ViewProps,
} from 'react-native';

type DicomViewerProps = ViewProps & {
  src?: string;
  hasScrollIndicator?: boolean;
  onSeriesEnd?: () => void;
  onSeriesBegin?: () => void;
};

const DicomViewer =
  UIManager.getViewManagerConfig('DicomViewerView') != null
    ? requireNativeComponent<DicomViewerProps>('DicomViewerView')
    : () => null;

export default DicomViewer;
