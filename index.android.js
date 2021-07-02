import PropTypes from "prop-types";
import React, { Component } from "react";
import {
  Dimensions,
  UIManager,
  findNodeHandle,
  requireNativeComponent,
  ViewPropTypes,
  StatusBar,
  BackHandler
} from "react-native";
import Orientation from "react-native-orientation-locker";

const VideoPlayer = requireNativeComponent("RCTAdvancedVideoControls", {
  name: "VideoPlayer",
  propTypes: {
    numberColor: PropTypes.string,
    ...ViewPropTypes
  }
});

export default class AndroidVideoPlayer extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isFullscreen: false,
      lockLandscape: false,
      lockPortrait: false
    };
  }

  componentWillMount() {
    Orientation.addDeviceOrientationListener(
      this.onOrientationDidChange.bind(this)
    );
    if (this.props.fullscreen != undefined && this.props.fullscreen != null) {
      this.setState({
        isFullscreen: this.props.fullscreen
      });
    }
    BackHandler.addEventListener("hardwareBackPress", this.onBackPressed);
  }

  componentWillUnmount() {
    Orientation.removeDeviceOrientationListener(
      this.onOrientationDidChange.bind(this)
    );
    BackHandler.removeEventListener("hardwareBackPress", this.onBackPressed);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.fullscreen != null && nextProps.fullscreen != undefined) {
      this.setState({
        isFullscreen: nextProps.fullscreen
      });

      if (nextProps.fullscreen) {
        StatusBar.setHidden(true);
      } else {
        StatusBar.setHidden(false);
      }
    }
  }

  onOrientationDidChange(orientation) {
    const { lockPortrait } = this.state;

    if (lockPortrait && !orientation.toLowerCase().includes("landscape")) {
      setTimeout(() => {
        Orientation.unlockAllOrientations();
        this.setState({
          lockLandscape: false,
          lockPortrait: false
        });
      }, 500);
    }
  }

  onBackPressed = () => {
    if (this.state.isFullscreen && this.props.showFullscreenControls != false) {
      this.leaveFullScreen();
    }
    if (this.props.onBackBtnPressed) {
      this.props.onBackBtnPressed();
    }
  };

  pause() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.RCTAdvancedVideoControls.Commands.pauseVideo,
      []
    );
  }

  play() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.RCTAdvancedVideoControls.Commands.playVideo,
      []
    );
  }

  killVideoPlayer() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.RCTAdvancedVideoControls.Commands.killPlayer,
      []
    );
  }

  mutePlayer() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.videoPlayer),
      UIManager.RCTAdvancedVideoControls.Commands.mutePlayer,
      []
    );
  }

  unmutePlayer() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.videoPlayer),
      UIManager.RCTAdvancedVideoControls.Commands.unmutePlayer,
      []
    );
  }

  goFullScreen = () => {
    if (this.props.onEnterFullscreen) {
      this.props.onEnterFullscreen();
    }

    this.setState({
      isFullscreen: true
    });

    StatusBar.setHidden(true);
    Orientation.lockToLandscape();
    this.setState({
      lockPortrait: false,
      lockLandscape: true
    });
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

  render() {
    var dWidth;
    var dHeight;

    if (Dimensions.get("window").width < Dimensions.get("window").height) {
      dWidth = Dimensions.get("window").height;
      dHeight = Dimensions.get("window").width;
    } else {
      dWidth = Dimensions.get("window").width;
      dHeight = Dimensions.get("window").height;
    }

    const { isFullscreen } = this.state;
    const vidContainerStyle = isFullscreen
      ? {
          width: dWidth,
          height: dHeight,
          position: "absolute",
          zIndex: 30,
          backgroundColor: "#000"
        }
      : this.props.playerStyle;

    return (
      <VideoPlayer
        ref={videoPlayer => (this.videoPlayer = videoPlayer)}
        seekBarColor={"#ffffff"}
        style={vidContainerStyle}
        fullscreen={isFullscreen}
        onFullscreen={this.goFullScreen}
        onBackPressed={this.leaveFullScreen}
        {...this.props}
      />
    );
  }
}
