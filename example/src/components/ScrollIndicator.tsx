import { View, StyleSheet } from 'react-native';

type ScrollIndicatorProps = {
  currentFrame: number;
  totalFrames: number;
};

const ScrollIndicator = ({
  currentFrame,
  totalFrames,
}: ScrollIndicatorProps) => {
  const progress = totalFrames > 1 ? currentFrame / (totalFrames - 1) : 0;
  const position = progress * 100;

  return (
    <View style={styles.container}>
      <View
        style={[
          styles.indicator,
          {
            top: `${position}%`,
          },
        ]}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
    backgroundColor: 'transparent',
  },
  indicator: {
    position: 'absolute',
    width: '100%',
    height: 2,
    backgroundColor: 'white',
    opacity: 0.5,
  },
});

export default ScrollIndicator;
