import React from 'react';
import { SafeAreaView, Text, StyleSheet, Button, Alert } from 'react-native';
import DicomViewer from 'react-native-dicom-viewer';

export default function App() {
  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>📄 DICOM Viewer Example</Text>
      <Button
        title="Load DICOM"
        onPress={() => {
          Alert.alert('Loading DICOM');
        }}
      />
      <DicomViewer style={styles.viewer} path="dummy.dcm" />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#111',
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    color: '#fff',
    fontSize: 20,
    marginBottom: 20,
  },
  viewer: {
    width: '90%',
    height: '70%',
    backgroundColor: '#222',
    borderRadius: 10,
  },
});
