package com.rn_advanced_video_player;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.media.AudioManager;
import android.os.Handler;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.RCTEventEmitter;

public class AdvancedVideoView extends FrameLayout {
    private ReactContext reactContext;
    private Activity myActivity;
    private FrameLayout screenLayout;
    private VideoPlayer videoPlayer;
    private AudioManager audio;

    public int containerWidth = 0;
    public int containerHeight = 0;

    private RelativeLayout swipeParentContainer;
    private LinearLayout swipeDetailsContainer;
    private TextView swipeSeconds;
    private TextView swipeCurrentTime;
    private TextView swipeVideoLength;
    private Boolean isSwiping = false;
    private Boolean canSwipeToSeek = true;
    private int swipeAmount;
    private int seekToInt;

    private double swipeThreshold = 25.0;

    //SET PROPS
    public boolean needSetFullscreenControlsProps = false;
    private Handler setFullscreenControlsPropsTimer = new Handler();
    //

    //Timers
    private Handler setSeekBarColorTimer = new Handler();
    private boolean doneSetSeekBarColor = false;

    private Handler setTitleTimer = new Handler();
    private Handler setIsLikeTimer = new Handler();
    private Handler setShowLikeBtnTimer = new Handler();
    private Handler setShowShareBtnTimer = new Handler();
    private Handler setShowDownloadBtnTimer = new Handler();

    public AdvancedVideoView(Context context) {
        super(context);
        reactContext = (ReactContext) context;
    }

    public AdvancedVideoView(final Context context, Activity activity) {
        super(context);
        reactContext = (ReactContext) context;
        myActivity = activity;
        screenLayout = (FrameLayout) activity.getLayoutInflater().inflate(R.layout.video, null);

        audio = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);

        initLayoutChangeListener();
        initSwipeGestures(context);

        this.addView(screenLayout);

        videoPlayer = new VideoPlayer(context, activity, screenLayout, new SpecialFunctions());
        videoPlayer.videoContainer = screenLayout.findViewById(R.id.videoContainer);
        videoPlayer.videoView = screenLayout.findViewById(R.id.surface_view);
        videoPlayer.videoView.avv = this;

        videoPlayer.exoView = screenLayout.findViewById(R.id.exoplayer);

        videoPlayer.videoContainer.removeViewAt(0);
    }

    //FUNCTIONS FOR JS TO CALL
    public void pauseVideo() {
        videoPlayer.pause(false);
    }

    public void playVideo() {
        videoPlayer.play(false);
    }

    public void killPlayer() {
        videoPlayer.killVideoPlayer(true);
        reactContext.getCurrentActivity().getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    public void mutePlayer() {
        videoPlayer.mutePlayer();
    }

    public void unmutePlayer() {
        videoPlayer.unmutePlayer();
    }
    ///////////////////////

    public void initVideoPlayer(String passedString) {
        if (videoPlayer.videoControls != null) {
            videoPlayer.isBuffering = true;
            videoPlayer.videoControls.setPlayPauseImage("buffering", false);
        }
        videoPlayer.videoUrl = passedString;
        videoPlayer.initializePlayer();
    }

    public class SpecialFunctions {
        public void toggleFullscreen() {
            WritableMap event = Arguments.createMap();
            reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "onFullscreen",
                    event);
        }

        public void backPressed() {
            WritableMap event = Arguments.createMap();
            reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "onBackPressed",
                    event);
        }

        public void likePressed() {
            WritableMap event = Arguments.createMap();
            reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "onLikePressed",
                    event);
        }

        public void sharePressed() {
            WritableMap event = Arguments.createMap();
            reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "onSharePressed",
                    event);
        }

        public void downloadPressed() {
            WritableMap event = Arguments.createMap();
            reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "onDownloadPressed",
                    event);
        }

        public void refreshPressed() {
            WritableMap event = Arguments.createMap();
            reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "onRefreshPressed",
                    event);
        }

        public void controlsShown() {
            WritableMap event = Arguments.createMap();
            reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "onControlsShow",
                    event);
        }

        public void controlsHidden() {
            WritableMap event = Arguments.createMap();
            reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "onControlsHide",
                    event);
        }
    }

    //PROPS FROM JS
    public void setShowFullscreenControls(final Boolean show) {
        if (needSetFullscreenControlsProps) {
            setFullscreenControlsPropsTimer.removeCallbacksAndMessages(null);
            if (videoPlayer != null && videoPlayer.videoControls != null) {
                needSetFullscreenControlsProps = false;
                videoPlayer.videoControls.setShowFullscreenControls(show);
            } else {
                setFullscreenControlsPropsTimer = new Handler();
                setFullscreenControlsPropsTimer.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        setShowFullscreenControls(show);
                    }
                }, 200);
            }
        }
    }

    public void setFullscreenImg(Boolean isFullScreen) {
        if (videoPlayer != null && videoPlayer.videoControls != null) {
            videoPlayer.videoControls.setFullscreenImg(isFullScreen);
        }
    }

    public void setSwipeToSeek(Boolean swipeToSeek) {
        canSwipeToSeek = swipeToSeek;
    }

    public void setIsLiked(Boolean isLiked) {
        if (videoPlayer != null && videoPlayer.videoControls != null && videoPlayer.videoControls.favButton != null) {
            setIsLikeTimer.removeCallbacksAndMessages(null);
            if (isLiked) {
                videoPlayer.videoControls.favButton.setBackgroundResource(R.drawable.favourite);
            } else {
                videoPlayer.videoControls.favButton.setBackgroundResource(R.drawable.bookmark);
            }
        } else {
            final Boolean copyIsLiked = isLiked;

            setIsLikeTimer = new Handler();
            setIsLikeTimer.postDelayed(new Runnable() {
                @Override
                public void run() {
                    setIsLiked(copyIsLiked);
                }
            }, 500);
        }
    }

    public void setTitle(final String title) {
        setTitleTimer.removeCallbacksAndMessages(null);
        if (videoPlayer != null && videoPlayer.videoControls != null && videoPlayer.videoControls.titleText != null) {
            videoPlayer.videoControls.titleText.setText(title);
        } else {
            setTitleTimer = new Handler();
            setTitleTimer.postDelayed(new Runnable() {
                @Override
                public void run() {
                    setTitle(title);
                }
            }, 500);
        }
    }

    public void setSeekBarColor(final String colorString) {
        if (!doneSetSeekBarColor && videoPlayer != null && videoPlayer.videoControls != null) {
            doneSetSeekBarColor = true;
            setSeekBarColorTimer.removeCallbacksAndMessages(null);
            videoPlayer.videoControls.seekBar.getProgressDrawable().setColorFilter(ColorHelper.getColorFromString(colorString), PorterDuff.Mode.SRC_IN);
            videoPlayer.videoControls.seekBar.getThumb().setColorFilter(ColorHelper.getColorFromString(colorString), PorterDuff.Mode.SRC_IN);
        } else {
            setSeekBarColorTimer = new Handler();
            setSeekBarColorTimer.postDelayed(new Runnable() {
                @Override
                public void run() {
                    setSeekBarColor(colorString);
                }
            }, 500);
        }
    }

    public void setShowLike(final boolean show) {
        if (videoPlayer != null && videoPlayer.videoControls != null) {
            setShowLikeBtnTimer.removeCallbacksAndMessages(null);
            videoPlayer.videoControls.hideButton("like", show);
        } else {
            setShowLikeBtnTimer = new Handler();
            setShowLikeBtnTimer.postDelayed(new Runnable() {
                @Override
                public void run() {
                    setShowLike(show);
                }
            }, 500);
        }
    }

    public void setShowShare(final boolean show) {
        if (videoPlayer != null && videoPlayer.videoControls != null) {
            setShowShareBtnTimer.removeCallbacksAndMessages(null);
            videoPlayer.videoControls.hideButton("share", show);
        } else {
            setShowShareBtnTimer = new Handler();
            setShowShareBtnTimer.postDelayed(new Runnable() {
                @Override
                public void run() {
                    setShowShare(show);
                }
            }, 500);
        }
    }

    public void setShowDownload(final boolean show) {
        if (videoPlayer != null && videoPlayer.videoControls != null) {
            setShowDownloadBtnTimer.removeCallbacksAndMessages(null);
            videoPlayer.videoControls.hideButton("download", show);
        } else {
            setShowDownloadBtnTimer = new Handler();
            setShowDownloadBtnTimer.postDelayed(new Runnable() {
                @Override
                public void run() {
                    setShowDownload(show);
                }
            }, 500);
        }
    }
    ///////////////

    public void updateSwipeUI() {
        String videoLength = MyHelper.getSeconds(videoPlayer.videoLength);
        String currentTime = MyHelper.getSeconds(seekToInt);

        if (swipeAmount > 0) {
            swipeSeconds.setText("+ " + String.valueOf(swipeAmount) + " seconds");
        } else {
            swipeSeconds.setText(String.valueOf(swipeAmount) + " seconds");
        }
        swipeCurrentTime.setText(currentTime);
        swipeVideoLength.setText(videoLength);
        swipeParentContainer.setBackgroundResource(R.color.black_see_through);
        swipeDetailsContainer.setAlpha(1);
    }

    public void initSwipeGestures(Context context) {
        swipeParentContainer = screenLayout.findViewById(R.id.swipeDetailsParentContainer);
        swipeDetailsContainer = screenLayout.findViewById(R.id.swipeDetailsContainer);
        swipeSeconds = screenLayout.findViewById(R.id.swipeSeconds);
        swipeCurrentTime = screenLayout.findViewById(R.id.swipe_current_time);
        swipeVideoLength = screenLayout.findViewById(R.id.swipe_video_length);

        screenLayout.setOnTouchListener(new OnSwipeTouchListener(context) {
            public void onClick() {
                if (videoPlayer.videoControls.isVisible) {
                    videoPlayer.videoControls.hideControls();
                } else {
                    videoPlayer.videoControls.showControls();
                }
            }

            public void onDoubleTapped() {
                if (videoPlayer.isLiveStream) return;
                if (videoPlayer.isPlaying) {
                    videoPlayer.pause(true);
                } else {
                    videoPlayer.play(true);
                }
            }

            public void onStartSwipe(MotionEvent me) {
                System.out.println("START SWIPE " + videoPlayer.canSeek);
                if (!canSwipeToSeek || videoPlayer.isLiveStream || !videoPlayer.canSeek) return;
                System.out.println("ENTERRRRR");
                if (videoPlayer != null && videoPlayer.videoControls != null) {
                    videoPlayer.videoControls.setDevSwipeStatus(checkVolOrBrtChanging(me), "start", me);
                }
                swipeAmount = 0;
                seekToInt = videoPlayer.currentTime;
            }

            public void onStopSwipe() {
                if (!canSwipeToSeek || videoPlayer.isLiveStream || !videoPlayer.canSeek) return;
                if (videoPlayer != null && videoPlayer.videoControls != null) {
                    videoPlayer.videoControls.setDevSwipeStatus("volume", "stop", null);
                }
                swipeParentContainer.setBackgroundColor(Color.TRANSPARENT);
                swipeDetailsContainer.setAlpha(0);
                isSwiping = false;

                if (swipeAmount != 0) {
                    videoPlayer.seekToPosition(seekToInt);
                    swipeAmount = 0;
                }
            }

            public void onSwipeRight(float distance) {
                if (!canSwipeToSeek || videoPlayer.isLiveStream || !videoPlayer.canSeek) return;
                if (!canSwipeToSeek) return;
                if (!isSwiping && distance < swipeThreshold) return;
                isSwiping = true;

                distance = distance / 5;

                if ((seekToInt + distance) >= videoPlayer.videoLength) {
                    swipeAmount += (videoPlayer.videoLength - seekToInt);
                    seekToInt = videoPlayer.videoLength;
                } else {
                    swipeAmount += (int) distance;
                    seekToInt += (int) distance;
                }
                updateSwipeUI();
            }

            public void onSwipeLeft(float distance) {
                if (!canSwipeToSeek || videoPlayer.isLiveStream || !videoPlayer.canSeek) return;
                if (!canSwipeToSeek) return;
                if (!isSwiping && distance < swipeThreshold) return;
                isSwiping = true;

                distance = distance / 5;

                if ((seekToInt - distance) <= 0) {
                    swipeAmount -= seekToInt;
                    seekToInt = 0;
                } else {
                    swipeAmount -= (int) distance;
                    seekToInt -= (int) distance;
                }
                updateSwipeUI();
            }

            public void onSwipeUp(float distance, MotionEvent me1, MotionEvent me2) {
//                int newSliderPos = getNewProgress(me2.getY(), volumeContainer.getHeight());
//                setDeviceVolume(newSliderPos);
//                volumeSeekBar.setProgress(newSliderPos);
                if (!isSwiping && videoPlayer != null && videoPlayer.videoControls != null) {
                    videoPlayer.videoControls.updateDevSwipeValues(checkVolOrBrtChanging(me1), distance, me1, me2);
                }
            }

            public void onSwipeDown(float distance, MotionEvent me1, MotionEvent me2) {
                if (!isSwiping && videoPlayer != null && videoPlayer.videoControls != null) {
                    videoPlayer.videoControls.updateDevSwipeValues(checkVolOrBrtChanging(me1), distance, me1, me2);
                }
            }
        });
    }

    public String checkVolOrBrtChanging(MotionEvent event) {
        int containerWidth = screenLayout.getWidth();

        if (event.getX() > containerWidth / 2) {
            return "volume";
        } else {
            return "brightness";
        }
    }

    public void initLayoutChangeListener() {
        screenLayout.addOnLayoutChangeListener(new OnLayoutChangeListener() {
            @Override
            public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
                Boolean widthChanged = v.getWidth() != containerWidth ? true : false;
                Boolean heightChanged = v.getHeight() != containerHeight ? true : false;

                if (!widthChanged && !heightChanged) return;
                if (widthChanged) containerWidth = v.getWidth();
                if (heightChanged) containerHeight = v.getHeight();

                if (videoPlayer != null && videoPlayer.videoControls != null && videoPlayer.videoView != null) {
                    videoPlayer.videoView.resizeVideo();
                    videoPlayer.videoControls.setSeekBarProgress();
                }
            }
        });
    }

    @Override
    public void requestLayout() {
        super.requestLayout();
        post(measureAndLayout);
    }

    private final Runnable measureAndLayout = new Runnable() {
        @Override
        public void run() {
            measure(
                    MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
                    MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
            layout(getLeft(), getTop(), getRight(), getBottom());
        }
    };
}
