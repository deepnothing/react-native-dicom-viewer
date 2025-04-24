# react-native-dicom-viewer

react-native-dicom-viewer is a React Native component for displaying DICOM images. It features a built-in DICOM file parser that does not rely on any third-party packages.

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



## Author
Teo Udovcic, teoudovcic@gmail.com

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
