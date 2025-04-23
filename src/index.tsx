import {
  requireNativeComponent,
  UIManager,
  type ViewProps,
} from 'react-native';

const COMPONENT_NAME = 'DicomViewerView';

type DicomViewerProps = ViewProps & {
  src?: string;
  hasScrollIndicator?: boolean;
};

const DicomViewer =
  UIManager.getViewManagerConfig(COMPONENT_NAME) != null
    ? requireNativeComponent<DicomViewerProps>(COMPONENT_NAME)
    : () => null;

export default DicomViewer;
