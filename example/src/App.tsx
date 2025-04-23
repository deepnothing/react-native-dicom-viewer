import { SafeAreaView, Text, View, StyleSheet } from 'react-native';
import DicomViewer from 'react-native-dicom-viewer';
import SeriesNotification from './components/SeriesNotification';
import ScrollIndicator from './components/ScrollIndicator';
import { useState, useEffect } from 'react';

export default function App() {
  const [showBeginNotification, setShowBeginNotification] = useState(false);
  const [showEndNotification, setShowEndNotification] = useState(false);
  const [currentFrame, setCurrentFrame] = useState(0);
  const [totalFrames, setTotalFrames] = useState(0);
  const [isInitialized, setIsInitialized] = useState(false);

  useEffect(() => {
    if (totalFrames > 0 && !isInitialized) {
      setIsInitialized(true);
    }
  }, [totalFrames]);

  const handleFrameChange = (event: {
    nativeEvent: { index: number; total: number };
  }) => {
    const { index, total } = event.nativeEvent;
    setCurrentFrame(index);
    setTotalFrames(total);

    // Only show notifications after first load
    if (isInitialized) {
      if (index === 0) {
        setShowEndNotification(false);
        setShowBeginNotification(true);
      } else if (index === total - 1) {
        setShowBeginNotification(false);
        setShowEndNotification(true);
      } else {
        // Hide both notifications when scrolling
        setShowBeginNotification(false);
        setShowEndNotification(false);
      }
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>React Native DICOM Viewer</Text>
      <Text style={styles.frameInfo}>
        Frame {currentFrame + 1} / {totalFrames}
      </Text>
      <View style={styles.viewerContainer}>
        <DicomViewer
          style={styles.viewer}
          src="test2.DCM"
          onFrameChange={handleFrameChange}
        />
        <ScrollIndicator
          currentFrame={currentFrame}
          totalFrames={totalFrames}
        />
        <SeriesNotification
          message="Beginning of Series"
          type="begin"
          visible={showBeginNotification}
          timeout={1000}
          onHide={() => setShowBeginNotification(false)}
        />
        <SeriesNotification
          message="End of Series"
          type="end"
          visible={showEndNotification}
          timeout={1000}
          onHide={() => setShowEndNotification(false)}
        />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#111',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
  },
  title: {
    color: '#fff',
    fontSize: 20,
    marginBottom: 20,
  },
  viewer: {
    width: '90%',
    aspectRatio: 1,
    backgroundColor: '#222',
    borderRadius: 10,
  },
  viewerContainer: {
    position: 'relative',
  },
  frameInfo: {
    color: '#fff',
    fontSize: 16,
    marginBottom: 10,
  },
});
