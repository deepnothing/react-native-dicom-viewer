# react-native-dicom-viewer

react-native-dicom-viewer is a React Native component designed for displaying medical images stored in the DICOM (Digital Imaging and Communications in Medicine) format

This library includes a built-in DICOM file parser written from scratch, with no reliance on third-party parsing libraries. It supports reading DICOM files bundled with the app or uploaded locally by the user, and has primarily been tested with Lossy JPEG-compressed DICOM images. 

## Installation

```sh
npm install react-native-dicom-viewer
```

## Usage

```js
import DicomViewer from 'react-native-dicom-viewer';

// ...

  const handleFrameChange = (event) => {
    const { index, total } = event.nativeEvent;
    setCurrentFrame(index);
    setTotalFrames(total);
  };

<DicomViewer
  style={styles.viewer}
  src={selectedFile}
  onFrameChange={handleFrameChange}
/>
```

## Demo

https://github.com/user-attachments/assets/666d8e90-cf27-47ce-9238-12a8eae81363


## Author
teoudovcic@gmail.com

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
