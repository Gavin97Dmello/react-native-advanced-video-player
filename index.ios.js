import {
  requireNativeComponent,
  UIManager,
  findNodeHandle,
  Dimensions
} from "react-native";
import SafeArea from "react-native-safe-area";
import PrefersHomeIndicatorAutoHidden from "react-native-home-indicator";

const VideoPlayer = requireNativeComponent("RCTAdvancedVideo");

import React, { Component } from "react";
import { View, StatusBar } from "react-native";
import Orientation from "react-native-orientation-locker";

export default class IosVideoPlayer extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isFullscreen: false,
      fullscreenStyle: {},
      lockLandscape: false,
      lockPortrait: false
    };
  }

  componentDidMount() {
    Orientation.addDeviceOrientationListener(
      this.onOrientationDidChange.bind(this)
    );

    if (this.props.fullscreen) {
      this.getFullscreenStyles();
      this.setState({
        isFullscreen: this.props.fullscreen
      });
    }
  }

  componentWillUnmount() {
    Orientation.removeDeviceOrientationListener(
      this.onOrientationDidChange.bind(this)
    );
  }

  componentWillReceiveProps(nextProps) {
    this.getFullscreenStyles();

    if (nextProps.fullscreen != undefined && nextProps.fullscreen != null) {
      this.setState({
        isFullscreen: nextProps.fullscreen
      });
    }
  }

  onOrientationDidChange(orientation) {
    const { lockPortrait } = this.state;

    if (lockPortrait && !orientation.toLowerCase().includes("landscape")) {
      Orientation.unlockAllOrientations();
      this.setState({
        lockLandscape: false,
        lockPortrait: false
      });
    }
  }

  pause() {
    if (this.videoPlayer) {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(this.videoPlayer),
        UIManager.RCTAdvancedVideo.Commands.pauseAvPlayer,
        []
      );
    }
  }

  play() {
    if (this.videoPlayer) {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(this.videoPlayer),
        UIManager.RCTAdvancedVideo.Commands.playAvPlayer,
        []
      );
    }
  }

  showSystemHUD() {
    if (this.videoPlayer) {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(this.videoPlayer),
        UIManager.RCTAdvancedVideo.Commands.showSystemHUD,
        []
      );
    }
  }

  killVideoPlayer() {
    if (this.videoPlayer) {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(this.videoPlayer),
        UIManager.RCTAdvancedVideo.Commands.killAvPlayer,
        []
      );
    }
  }

  mutePlayer() {
    if (this.videoPlayer) {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(this.videoPlayer),
        UIManager.RCTAdvancedVideo.Commands.mutePlayer,
        []
      );
    }
  }

  unmutePlayer() {
    if (this.videoPlayer) {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(this.videoPlayer),
        UIManager.RCTAdvancedVideo.Commands.unmutePlayer,
        []
      );
    }
  }

  goFullScreen = () => {
    if (this.props.onEnterFullscreen) {
      this.props.onEnterFullscreen();
    }

    this.getFullscreenStyles();

    this.setState({
      isFullscreen: true
    });

    StatusBar.setHidden(true);
    Orientation.lockToLandscape();
    this.setState({
      lockPortrait: false,
      lockLandscape: true
    });

    this.getFullscreenStyles();
  };

  leaveFullScreen = () => {
    if (this.props.onLeaveFullscreen) {
      this.props.onLeaveFullscreen();
    }

    this.setState({
      isFullscreen: false
    });

    StatusBar.setHidden(false);

    Orientation.getDeviceOrientation(res => {
      if (res.toLowerCase().includes("landscape")) {
        Orientation.lockToPortrait();
        this.setState({
          lockLandscape: false,
          lockPortrait: true
        });
      } else if (res.toLowerCase().includes("portrait")) {
        if (res == "PORTRAIT-UPSIDEDOWN" || !this.state.lockLandscape) {
          Orientation.lockToPortrait();
          this.setState({
            lockLandscape: false,
            lockPortrait: true
          });
        } else {
          Orientation.unlockAllOrientations();
          this.setState({
            lockPortrait: false,
            lockLandscape: false
          });
        }
      } else {
        Orientation.lockToPortrait();
        this.setState({
          lockLandscape: false,
          lockPortrait: true
        });
      }
    });
  };

  getDevOrientation = () => {
    const { lockedLandscape, lockedPortrait } = this.state;

    const width = Dimensions.get("window").width;
    const height = Dimensions.get("window").height;

    if (lockedLandscape) {
    } else {
    }
    if (width > height) {
      return "landscape";
    } else {
      return "portrait";
    }
  };

  getFullscreenStyles = () => {
    SafeArea.getSafeAreaInsetsForRootView().then(res => {
      const sa = res.safeAreaInsets;
      var wHeight, wWidth;
      if (Dimensions.get("window").width < Dimensions.get("window").height) {
        wWidth = Dimensions.get("window").height;
        wHeight = Dimensions.get("window").width;
      } else {
        wWidth = Dimensions.get("window").width;
        wHeight = Dimensions.get("window").height;
      }

      const fullscreenStyle = {
        position: "absolute",
        zIndex: 30,
        width: wWidth,
        height: wHeight,
        paddingLeft: sa.left,
        paddingRight: sa.right,
        // paddingBottom: sa.bottom,
        backgroundColor: "#000"
      };

      this.setState({
        fullscreenStyle
      });
    });
  };

  render() {
    const { isFullscreen, fullscreenStyle } = this.state;
    const { playerStyle } = this.props;

    return (
      <View style={isFullscreen ? fullscreenStyle : playerStyle}>
        <VideoPlayer
          ref={videoPlayer => (this.videoPlayer = videoPlayer)}
          style={{ width: "100%", height: "100%" }}
          isFullscreen={isFullscreen}
          seekBarColor={"#ffffff"}
          onFullscreen={this.goFullScreen}
          onBackPressed={this.leaveFullScreen}
          showHomeIndicator={!isFullscreen}
          {...this.props}
        />
        {isFullscreen && <PrefersHomeIndicatorAutoHidden />}
      </View>
    );
  }
}
