import { SafeAreaView, Text, View, StyleSheet } from 'react-native';
import DicomViewer from 'react-native-dicom-viewer';
import ScrollIndicator from './components/ScrollIndicator';
import { useState } from 'react';

export default function App() {
  const [currentFrame, setCurrentFrame] = useState(0);
  const [totalFrames, setTotalFrames] = useState(0);

  const handleFrameChange = (event: {
    nativeEvent: { index: number; total: number };
  }) => {
    const { index, total } = event.nativeEvent;
    setCurrentFrame(index);
    setTotalFrames(total);
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
