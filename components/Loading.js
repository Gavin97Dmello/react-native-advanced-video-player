import React from "react";
import { View, Platform } from "react-native";
import {
  UIActivityIndicator,
  MaterialIndicator
} from "react-native-indicators";

function LoadingIcon() {
  if (Platform.OS === "android") return <MaterialIndicator color="#fff" />;
  return <UIActivityIndicator color="#fff" />;
}

function Loading({ visible, overlay = false }) {
  if (!visible) {
    return <View style={{ height: 0 }} />;
  } else if (overlay) {
    return (
      <View style={styles.overlayContainer}>
        <LoadingIcon />
      </View>
    );
  }
  return <View style={{alignSelf: "center"}}><LoadingIcon /></View>;
}

const styles = {
  overlayContainer: {
    width: "100%",
    height: "100%",
    position: "absolute"
  }
};

export { Loading };