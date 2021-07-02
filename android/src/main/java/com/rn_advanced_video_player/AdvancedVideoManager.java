package com.rn_advanced_video_player;

import androidx.annotation.Nullable;

import com.facebook.infer.annotation.Assertions;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.HashMap;
import java.util.Map;

public class AdvancedVideoManager extends SimpleViewManager<AdvancedVideoView> {

    private static final String REACT_CLASS = "RCTAdvancedVideoControls";

    public static final int PAUSE_VIDEO = 1;
    public static final int PLAY_VIDEO = 2;
    public static final int KILL_PLAYER = 3;
    public static final int MUTE_PLAYER = 4;
    public static final int UNMUTE_PLAYER = 5;

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected AdvancedVideoView createViewInstance(ThemedReactContext reactContext) {
        return new AdvancedVideoView(reactContext, reactContext.getCurrentActivity());
    }

    @ReactProp(name = "source")
    public void setSource(AdvancedVideoView view, String url) {
        view.initVideoPlayer(url);
    }

    @ReactProp(name = "showFullscreenControls")
    public void setShowFullscreenControls(AdvancedVideoView view, Boolean show) {
        view.needSetFullscreenControlsProps = true;
        view.setShowFullscreenControls(show);
    }

    @ReactProp(name = "fullscreen")
    public void setFullScreenImg(AdvancedVideoView view, Boolean isFullscreen) {
        view.setFullscreenImg(isFullscreen);
    }

    @ReactProp(name = "swipeToSeek")
    public void setSwipeToSeek(AdvancedVideoView view, Boolean swipeToSeek) {
        view.setSwipeToSeek(swipeToSeek);
    }

    @ReactProp(name = "isLiked")
    public void setIsLiked(AdvancedVideoView view, Boolean isLiked) {
        view.setIsLiked(isLiked);
    }

    @ReactProp(name = "title")
    public void setTitle(AdvancedVideoView view, String title) {
        view.setTitle(title);
    }

    @ReactProp(name = "seekBarColor")
    public void setSeekBarColor(AdvancedVideoView view, String colorString) {
        view.setSeekBarColor(colorString);
    }

    @ReactProp(name = "showLikeButton")
    public void setShowLike(AdvancedVideoView view, Boolean show) {
        view.setShowLike(show);
    }

    @ReactProp(name = "showShareButton")
    public void setShowShare(AdvancedVideoView view, Boolean show) {
        view.setShowShare(show);
    }

    @ReactProp(name = "showDownloadButton")
    public void setShowDownload(AdvancedVideoView view, Boolean show) {
        view.setShowDownload(show);
    }

    @Override
    public Map<String, Integer> getCommandsMap() {
        return MapBuilder.of(
                "pauseVideo",
                PAUSE_VIDEO,
                "playVideo",
                PLAY_VIDEO,
                "killPlayer",
                KILL_PLAYER,
                "mutePlayer",
                MUTE_PLAYER,
                "unmutePlayer",
                UNMUTE_PLAYER);
    }

    @Override
    public void receiveCommand(
            AdvancedVideoView view,
            int commandType,
            @Nullable ReadableArray args) {
        Assertions.assertNotNull(view);
        Assertions.assertNotNull(args);
        switch (commandType) {
            case PAUSE_VIDEO: {
                view.pauseVideo();
                return;
            }
            case PLAY_VIDEO: {
                view.playVideo();
                return;
            }
            case KILL_PLAYER: {
                view.killPlayer();
                return;
            }
            case MUTE_PLAYER: {
                view.mutePlayer();
                return;
            }
            case UNMUTE_PLAYER: {
                view.unmutePlayer();
                return;
            }
            default:
                throw new IllegalArgumentException(String.format(
                        "Unsupported command %d received by %s.",
                        commandType,
                        getClass().getSimpleName()));
        }
    }

    @Override
    public Map getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.builder().put("onFullscreen", (Object) MapBuilder.of("registrationName", "onFullscreen")).put("onBackPressed",
                (Object) MapBuilder.of("registrationName", "onBackPressed")).put("onLikePressed",
                (Object) MapBuilder.of("registrationName", "onLikePressed")).put("onSharePressed",
                (Object) MapBuilder.of("registrationName", "onSharePressed")).put("onDownloadPressed",
                (Object) MapBuilder.of("registrationName", "onDownloadPressed")).put("onRefreshPressed",
                (Object) MapBuilder.of("registrationName", "onRefreshPressed")).put("onControlsShow",
                (Object) MapBuilder.of("registrationName", "onControlsShow")).put("onControlsHide",
                (Object) MapBuilder.of("registrationName", "onControlsHide")).build();
    }
}
