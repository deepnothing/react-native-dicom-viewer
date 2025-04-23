# react-native-dicom-viewer

react native dicom viewer

## Installation

```sh
npm install react-native-dicom-viewer
```

## Usage

```js
import DicomViewer from 'react-native-dicom-viewer';

// ...

  const handleFrameChange = (event: {
    nativeEvent: { index: number; total: number };
  }) => {
    const { index, total } = event.nativeEvent;
    setCurrentFrame(index);
    setTotalFrames(total);
  };

<DicomViewer
  style={styles.viewer}
  src="test2.DCM"
  onFrameChange={handleFrameChange}
/>
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
