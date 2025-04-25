import { useState } from 'react';
import {
  SafeAreaView,
  Text,
  View,
  StyleSheet,
  Button,
  Platform,
} from 'react-native';
import DicomViewer from 'react-native-dicom-viewer';
import { pick } from '@react-native-documents/picker';
import ScrollIndicator from './components/ScrollIndicator';

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

  const pickFile = async () => {
    try {
      const [result] = await pick({
        type: Platform.select({
          ios: ['public.data', 'public.content', 'public.item'],
          android: ['*/*'],
        }),
      });

      const filePath = Platform.select({
        ios: result.uri.replace('file://', ''),
        android: result.uri,
      });

      if (filePath) {
        setSelectedFile(filePath);
      }
    } catch (err: unknown) {
      console.error('Error picking document:', err);
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
          src={selectedFile}
          onFrameChange={handleFrameChange}
        />
        <ScrollIndicator
          currentFrame={currentFrame}
          totalFrames={totalFrames}
        />
      </View>

      <View style={styles.buttonsContainer}>
        <View style={styles.buttonSection}>
          {demoFiles.map((file, index) => (
            <Button
              key={index}
              title={file}
              onPress={() => setSelectedFile(file)}
            />
          ))}
        </View>

        <Button title="Upload DICOM File" onPress={pickFile} />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#2a2a2a',
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
    width: '90%',
    marginTop: 20,
  },
  buttonSection: {
    marginBottom: 15,
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 10,
  },
});
