import {
  requireNativeComponent,
  UIManager,
  type ViewProps,
} from 'react-native';

type DicomViewerProps = ViewProps & {
  /**
   * The source URL or path to the DICOM file to be displayed.
   */
  src?: string;

  /**
   * Callback triggered when the displayed frame changes.
   * 
   * @param event - Event sent from native code .
   * @param event.nativeEvent.index - The index of the currently displayed frame (0-based).
   * @param event.nativeEvent.total - The total number of frames in the DICOM file.
   */
  onFrameChange?: (event: {
    nativeEvent: { index: number; total: number };
  }) => void;
};


const DicomViewer =
  UIManager.getViewManagerConfig('DicomViewerView') != null
    ? requireNativeComponent<DicomViewerProps>('DicomViewerView')
    : () => null;

export default DicomViewer;
