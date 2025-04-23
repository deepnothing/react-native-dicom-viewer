import { SafeAreaView, Text, View, StyleSheet } from 'react-native';
import DicomViewer from 'react-native-dicom-viewer';
import SeriesNotification from './components/SeriesNotification';
import { useState, useRef } from 'react';

export default function App() {
  const [showBeginNotification, setShowBeginNotification] = useState(false);
  const [showEndNotification, setShowEndNotification] = useState(false);
  const isFirstLoad = useRef(true);

  const handleSeriesEnd = () => {
    setShowBeginNotification(false);
    setShowEndNotification(true);
  };

  const handleSeriesBegin = () => {
    if (isFirstLoad.current) {
      isFirstLoad.current = false;
      return;
    }
    setShowEndNotification(false);
    setShowBeginNotification(true);
  };

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>React Native DICOM Viewer</Text>
      <View style={styles.viewerContainer}>
        <DicomViewer
          style={styles.viewer}
          src="test2.DCM"
          onSeriesBegin={handleSeriesBegin}
          onSeriesEnd={handleSeriesEnd}
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
});
