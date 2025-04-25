# react-native-dicom-viewer

react-native-dicom-viewer is a React Native component for displaying DICOM images. It features a built-in DICOM file parser that does not rely on any third-party packages. The library can read files in the app bundle or local upload by the user and has mostly been tested with Lossy JPEG compressed DICOM files.

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
