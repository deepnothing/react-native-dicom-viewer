import React, { useEffect } from 'react';
import { View, Text, StyleSheet } from 'react-native';

type Props = {
  message: string;
  type: 'begin' | 'end';
  visible: boolean;
  timeout?: number;
  onHide: () => void;
};

const SeriesNotification = ({ message, type, visible, timeout = 1000, onHide }: Props) => {
  useEffect(() => {
    if (visible) {
      const timer = setTimeout(onHide, timeout);
      return () => clearTimeout(timer);
    }
  }, [visible, timeout, onHide]);

  if (!visible) return null;

  return (
    <View style={[styles.container, type === 'begin' ? styles.beginContainer : styles.endContainer]}>
      <Text style={[styles.text, type === 'begin' ? styles.beginText : styles.endText]}>
        {message}
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    alignSelf: 'center',
    width: 180,
    padding: 8,
    borderRadius: 20,
    alignItems: 'center',
  },
  beginContainer: {
    top: 10,
    backgroundColor: '#d4edda',
    borderWidth: 1,
    borderColor: '#155724',
  },
  endContainer: {
    bottom: 10,
    backgroundColor: '#f8d7da',
    borderWidth: 1,
    borderColor: '#721c24',
  },
  text: {
    fontSize: 12,
    fontWeight: '600',
  },
  beginText: {
    color: '#155724',
  },
  endText: {
    color: '#721c24',
  },
});

export default SeriesNotification;
