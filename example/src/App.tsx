import { SafeAreaView, Text, View, StyleSheet, Button } from 'react-native';
import DicomViewer from 'react-native-dicom-viewer';
import ScrollIndicator from './components/ScrollIndicator';
import { useState } from 'react';

const demoFiles = ['test1.DCM', 'test2.DCM'];

export default function App() {
  const [currentFrame, setCurrentFrame] = useState(0);
  const [totalFrames, setTotalFrames] = useState(0);
  const [selectedFile, setSelectedFile] = useState(demoFiles[1]);

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
          src={selectedFile}
          onFrameChange={handleFrameChange}
        />
        <ScrollIndicator
          currentFrame={currentFrame}
          totalFrames={totalFrames}
        />
      </View>

      <View style={styles.buttonsContainer}>
        {demoFiles.map((file, index) => (
          <Button
            key={index}
            title={file}
            onPress={() => setSelectedFile(file)}
          />
        ))}
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
  },
  viewerContainer: {
    position: 'relative',
  },
  frameInfo: {
    color: '#fff',
    fontSize: 16,
    marginBottom: 10,
  },
  buttonsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    width: '90%',
    marginTop: 20,
  },
});
