import AndroidVideoPlayer from "./index.android";
import IosVideoPlayer from "./index.ios";
import { Platform } from "react-native";

const RNVideoPlayer = Platform.OS === "android" ? AndroidVideoPlayer : IosVideoPlayer;

export default RNVideoPlayer;