package com.rn_advanced_video_player;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.graphics.Color;
import android.media.AudioManager;
import android.os.Handler;
import android.os.Message;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import com.github.ybq.android.spinkit.SpinKitView;
import com.lukelorusso.verticalseekbar.VerticalSeekBar;

import java.util.HashMap;
import java.util.Map;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;

public class VideoControls {
    private Context myContext;
    private Activity myActivity;
    private TimeHelper timeHelper;
    private Window window;
    private WindowManager.LayoutParams layoutParams;
    private VideoPlayer.VideoFunctions videoFns;

    // SHOW BUTTON PARAMS
    public boolean showLikeButton = true;
    public boolean showShareButton = true;
    public boolean showDownloadButton = true;
    public boolean showFullscreenControls = true;

    ///////////LAYOUT PARAMS///////////

    private FrameLayout screenLayout;
    public LinearLayout topLayout;
    public ImageButton backButton;
    public TextView titleText;
    public ImageButton favButton;
    public ImageButton shareButton;
    public ImageButton dlButton;
    public ImageButton refreshButton;

    public ImageButton playPauseButton;
    public SpinKitView spinner;

    public RelativeLayout brightnessContainer;
    public ImageButton brightnessIcon;
    public VerticalSeekBar brightnessSeekBar;
    public RelativeLayout volumeContainer;
    public ImageButton volumeIcon;
    public VerticalSeekBar volumeSeekBar;

    public LinearLayout btmLayout;
    public RelativeLayout dummyView;
    public ImageButton zoomButton;
    public TextView currentTime;
    public TextView videoLength;
    public SeekBar seekBar;

    /////////////////////////////////////////////

    private AudioManager audio;
    private ContentResolver cResolver;

    public Boolean isVisible = false;

    private boolean isSeeking = false;
    private int currentTimeInt = 0;
    private int videoLengthInt = 0;

    private boolean skipVolSeek = false;
    private boolean skipVolListener = false;
    private int maxVolume = 0;
    private double lastBrightnessProgress = 0.0;
    private double lastVolProgress = 0.0;
    private double startLocation = 0.0;

    private int timeToHideControls = 2000;
    private Handler hidePlayStatusTimer = new Handler();
    private Handler hideControlsTimer = new Handler();
    private Handler restartVolSeek = new Handler();

    private int seekToInt;

    public VideoControls(Context context, Activity activity, FrameLayout frameLayout, VideoPlayer.VideoFunctions videoFunctions) {
        myContext = context;
        myActivity = activity;
        screenLayout = frameLayout;
        videoFns = videoFunctions;
    }

    public void initializeControls() {
        audio = (AudioManager) myContext.getSystemService(Context.AUDIO_SERVICE);
        maxVolume = audio.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        cResolver = myContext.getApplicationContext().getContentResolver();
        timeHelper = new TimeHelper();

        playPauseButton = screenLayout.findViewById(R.id.pause_play_button);
        spinner = screenLayout.findViewById(R.id.spinner);
        setPlayPauseImage("buffering", false);

        topLayout = screenLayout.findViewById(R.id.top_layout);
        backButton = screenLayout.findViewById(R.id.back_button);
        titleText = screenLayout.findViewById(R.id.titleText);
        favButton = screenLayout.findViewById(R.id.like_button);
        shareButton = screenLayout.findViewById(R.id.share_button);
        dlButton = screenLayout.findViewById(R.id.download_button);
        refreshButton = screenLayout.findViewById(R.id.refresh_button);

        btmLayout = screenLayout.findViewById(R.id.btm_layout);
        currentTime = screenLayout.findViewById(R.id.current_time);
        videoLength = screenLayout.findViewById(R.id.video_length);
        seekBar = screenLayout.findViewById(R.id.seek_bar);
        dummyView = screenLayout.findViewById(R.id.dummy_view);
        zoomButton = screenLayout.findViewById(R.id.zoom_button);
        brightnessIcon = screenLayout.findViewById(R.id.brightness_icon);
        brightnessContainer = screenLayout.findViewById(R.id.brightnessContainer);
        brightnessSeekBar = screenLayout.findViewById(R.id.brightness_seekbar);
        volumeIcon = screenLayout.findViewById(R.id.volume_icon);
        volumeContainer = screenLayout.findViewById(R.id.volumeContainer);
        volumeSeekBar = screenLayout.findViewById(R.id.volume_seekbar);

        setFullscreenImg(false);
        initSeekbars(myContext);
        initButtonClickListeners(myContext);
        initDeviceHardwareListener(myContext);

        hideControls();

        screenLayout.setFocusable(true);
        screenLayout.requestFocus();
        screenLayout.setFocusableInTouchMode(true);
    }

    //FUNCTIONS FOR PARENT TO CALL
    public void updateProgress(long timeNow, long timeLength) {
        if (isSeeking) return;
        currentTimeInt = (int) timeNow / 1000;
        videoLengthInt = (int) timeLength / 1000;

        String stringCurrentTime = MyHelper.getSeconds(currentTimeInt);
        currentTime.setText(stringCurrentTime);

        String stringVideoLength = MyHelper.getSeconds(videoLengthInt);
        videoLength.setText(stringVideoLength);

        seekBar.setMax(videoLengthInt);
        seekBar.setProgress(currentTimeInt);
    }

    public void setPlayPauseImage(String type, Boolean btnVisible) {
        switch (type) {
            case "pause": {
                if (videoFns.isBuffering()) return;
                spinner.setAlpha(0);
                playPauseButton.setTag(R.drawable.pause);
                playPauseButton.setBackgroundResource(R.drawable.pause);
                break;
            }
            case "play": {
                if (videoFns.isBuffering()) return;
                spinner.setAlpha(0);
                playPauseButton.setTag(R.drawable.play);
                playPauseButton.setBackgroundResource(R.drawable.play);
                break;
            }
            case "buffering": {
                playPauseButton.setVisibility(View.INVISIBLE);
                spinner.setAlpha(1);
                break;
            }
            default: {
                spinner.setAlpha(0);
                playPauseButton.setTag(R.drawable.pause);
                playPauseButton.setBackgroundResource(R.drawable.pause);
                playPauseButton.setVisibility(View.VISIBLE);
                break;
            }
        }
        if (type != "buffering") {
            if (btnVisible) playPauseButton.setVisibility(View.VISIBLE);
            hidePlayStatusTimer.removeCallbacksAndMessages(null);
            hidePlayStatusTimer = new Handler();
            hidePlayStatusTimer.postDelayed(new Runnable() {
                @Override
                public void run() {
                    playPauseButton.setVisibility(View.INVISIBLE);
                }
            }, 500);
        }
    }

    public void setShowFullscreenControls(Boolean show) {
        showFullscreenControls = show;

        if (!showFullscreenControls) {
            int btmChildCount = btmLayout.getChildCount();
            String topFirstChild = (String) topLayout.getChildAt(0).getTag();
            String btmLastChild = (String) btmLayout.getChildAt(btmChildCount - 1).getTag();

            if (btmLastChild != null && btmLastChild.equals("zoomBtn")) {
                btmLayout.removeViewAt(btmChildCount - 1);
            }

            if (topFirstChild.equals("backBtn")) {
                topLayout.removeViewAt(0);
            }
        }
    }

    public void setFullscreenImg(Boolean isFullScreen) {
        if (!showFullscreenControls) return;

        int btmChildCount = btmLayout.getChildCount();
        String topFirstChild = (String) topLayout.getChildAt(0).getTag();
        String btmLastChild = (String) btmLayout.getChildAt(btmChildCount - 1).getTag();

        if (isFullScreen) {
            if (btmLastChild != null && btmLastChild.equals("zoomBtn")) {
                btmLayout.removeViewAt(btmChildCount - 1);
            }

            if (!topFirstChild.equals("backBtn")) {
                topLayout.addView(backButton, 0);
            }
        } else {
            if (btmLastChild == null || !btmLastChild.equals("zoomBtn")) {
                btmLayout.addView(zoomButton);
            }

            if (topFirstChild.equals("backBtn")) {
                topLayout.removeViewAt(0);
            }
        }
    }

    public void hideButton(String button, boolean show) {
        if (show == false) {
            String btnTag = button + "Btn";
            int childCount = topLayout.getChildCount();
            int found = -1;

            for (int i = 0; i < childCount; i++) {
                if (topLayout.getChildAt(i).getTag() != null && topLayout.getChildAt(i).getTag().equals(btnTag)) {
                    found = i;
                }
            }

            if (found != -1) {
                topLayout.removeViewAt(found);
            }
        }
    }

    ///////UI FUNCTIONS
    public void hideControls() {
        stopTimer();

        isVisible = false;
        topLayout.setAlpha(0);
        btmLayout.setAlpha(0);
        currentTime.setAlpha(0);
        seekBar.setAlpha(0);
        videoLength.setAlpha(0);
        volumeIcon.setVisibility(View.INVISIBLE);
        volumeContainer.setAlpha(0);
        brightnessIcon.setVisibility(View.INVISIBLE);
        brightnessContainer.setAlpha(0);
        playPauseButton.setVisibility(View.INVISIBLE);
        zoomButton.setVisibility(View.INVISIBLE);

        videoFns.controlsHidden();
    }

    public void showControls() {
        stopTimer();

        isVisible = true;
        topLayout.setAlpha(1);
        btmLayout.setAlpha(1);
        currentTime.setAlpha(1);
        seekBar.setAlpha(1);
        videoLength.setAlpha(1);
        volumeIcon.setVisibility(View.VISIBLE);
        volumeContainer.setAlpha(1);
        brightnessIcon.setVisibility(View.VISIBLE);
        brightnessContainer.setAlpha(1);
        zoomButton.setVisibility(View.VISIBLE);

        videoFns.controlsShown();
        restartTimer();
    }

    public void restartTimer() {
        hideControlsTimer.removeCallbacksAndMessages(null);
        hideControlsTimer = new Handler();
        hideControlsTimer.postDelayed(new Runnable() {
            @Override
            public void run() {
                hideControls();
            }
        }, timeToHideControls);
    }

    public void switchControls(String type) {
        LinearLayout layoutToAdd;
        String[] btmRemovables;
        String[] topRemovables;
        Map<LinearLayout, String[]> toRemove = new HashMap<>();

        int i = 0, j = 0, found = -1;
        View child = null;

        if (type == "live" || type == "rtmp") {
            layoutToAdd = topLayout;
            btmRemovables = new String[]{"currentTimeText", "videoSeekBar", "videoLengthText"};
            topRemovables = new String[]{""};

            toRemove.put(btmLayout, btmRemovables);
            toRemove.put(topLayout, topRemovables);
        } else {
            layoutToAdd = btmLayout;
            btmRemovables = new String[]{"dummyView"};
            topRemovables = new String[]{"refreshBtn"};

            toRemove.put(btmLayout, btmRemovables);
            toRemove.put(topLayout, topRemovables);
        }

        for (Map.Entry<LinearLayout, String[]> item: toRemove.entrySet()) {
            LinearLayout layoutToRemove = item.getKey();
            String[] removables = item.getValue();

            for (i = 0; i < removables.length; i++) {
                found = -1;
                child = null;

                for (j = 0; j < layoutToRemove.getChildCount(); j++) {
                    child = layoutToRemove.getChildAt(j);
                    if (child.getTag() != null && child.getTag().equals(removables[i])) {
                        found = j;
                    }
                }

                if (found > -1) {
                    layoutToRemove.removeViewAt(found);
                }
            }
        }

        if (type == "live" || type == "rtmp") {
            if (refreshButton.getParent() == null) layoutToAdd.addView(refreshButton, layoutToAdd.getChildCount());
            if (dummyView.getParent() == null) btmLayout.addView(dummyView, 0);
        } else {
            if (videoLength.getParent() == null) layoutToAdd.addView(videoLength, 0);
            if (seekBar.getParent() == null) layoutToAdd.addView(seekBar, 0);
            if (currentTime.getParent() == null) layoutToAdd.addView(currentTime, 0);
        }
    }
    /////////LISTENERS

    public void setDevSwipeStatus(String type, String status, MotionEvent me) {
        ImageButton icon = brightnessIcon;
        RelativeLayout container = brightnessContainer;

        if (type == "volume") {
            icon = volumeIcon;
            container = volumeContainer;
        }

        if (status == "start") {
            skipVolListener = true;
            skipVolSeek = true;
            startLocation = me.getY();
            stopTimer();
        } else {
            skipVolListener = false;
            skipVolSeek = false;
            restartTimer();
        }
    }

    public void updateDevSwipeValues(String type, float distance, MotionEvent me1, MotionEvent me2) {
        stopTimer();

        ImageButton icon = brightnessIcon;
        RelativeLayout container = brightnessContainer;
        VerticalSeekBar vSeekBar = brightnessSeekBar;

        int newSliderPos;
        newSliderPos = getNewProgress(me2.getY(), container.getHeight());

        if (type == "volume") {
            icon = volumeIcon;
            container = volumeContainer;
            vSeekBar = volumeSeekBar;
            icon.setVisibility(View.VISIBLE);
            container.setAlpha(1);
            newSliderPos = setDeviceVolume(container.getHeight(), distance, me2);
        } else {
            icon.setVisibility(View.VISIBLE);
            container.setAlpha(1);
            newSliderPos = setDeviceBrightness(container.getHeight(), distance, me2);
        }

        vSeekBar.setProgress(newSliderPos);
    }

    public void stopTimer() {
        hideControlsTimer.removeCallbacksAndMessages(null);
    }

    public void initDeviceHardwareListener(Context context) {
        SettingsContentObserver mSettingsContentObserver = new SettingsContentObserver(context, new Handler() {
            @Override
            public void handleMessage(Message msg) {
                if (!skipVolListener) {
//                    volumeIcon.setVisibility(View.VISIBLE);
//                    volumeContainer.setAlpha(1);
                    restartVolSeek.removeCallbacksAndMessages(null);
                    skipVolSeek = true;

                    double doubleMaxVol = (double) maxVolume;
                    double volPercent = (double) (msg.arg1 / doubleMaxVol);
                    double newVolume = volPercent * 100.0;
                    int roundedVolume = (int) Math.ceil(newVolume);
                    lastVolProgress = (double) roundedVolume;
                    volumeSeekBar.setProgress(roundedVolume);

                    restartTimer();
                    super.handleMessage(msg);

                    restartVolSeek = new Handler();
                    restartVolSeek.postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            skipVolSeek = false;
                        }
                    }, 500);
                }
            }
        });
        context.getApplicationContext().getContentResolver().registerContentObserver(
                android.provider.Settings.System.CONTENT_URI, true,
                mSettingsContentObserver);
    }

    public void initButtonClickListeners(final Context context) {
        backButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!isVisible) return;
                videoFns.backPressed();
                restartTimer();
            }
        });

        favButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!isVisible) return;
                videoFns.likePressed();
                restartTimer();
            }
        });

        shareButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!isVisible) return;
                videoFns.sharePressed();
                restartTimer();
            }
        });

        dlButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!isVisible) return;
                videoFns.downloadPressed();
                restartTimer();
            }
        });

        playPauseButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!isVisible) return;
                videoFns.togglePlayStatus();
                restartTimer();
            }
        });

        zoomButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!isVisible) return;
                videoFns.toggleFullscreen();
                restartTimer();
            }
        });

        refreshButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!isVisible) return;
                videoFns.seekToLivePosition();
                restartTimer();
            }
        });
    }

    public void initSeekbars(Context context) {
        setSeekBarProgress();

        brightnessSeekBar.setOnProgressChangeListener(
                new Function1<Integer, Unit>() {
                    @Override
                    public Unit invoke(Integer progressValue) {
                        brightnessIcon.setVisibility(View.VISIBLE);
                        brightnessContainer.setAlpha(1);

                        lastBrightnessProgress = (double) progressValue;
                        layoutParams.screenBrightness = (float) (lastBrightnessProgress / 100.0);

                        if (layoutParams.screenBrightness > 1.0f) {
                            layoutParams.screenBrightness = 1.0f;
                        } else if (layoutParams.screenBrightness < 0.1f) {
                            layoutParams.screenBrightness = 0.1f;
                        }

                        window.setAttributes(layoutParams);
                        restartTimer();
                        return null;
                    }
                }
        );

        volumeSeekBar.setOnProgressChangeListener(
                new Function1<Integer, Unit>() {
                    @Override
                    public Unit invoke(Integer progressValue) {
                        if (skipVolSeek) {
                            return null;
                        }

                        volumeIcon.setVisibility(View.VISIBLE);
                        volumeContainer.setAlpha(1);

                        lastVolProgress = (double) progressValue;
                        int newVolume = (int) (progressValue / 100.0 * maxVolume);
                        audio.setStreamVolume(AudioManager.STREAM_MUSIC, newVolume, 0);

                        restartTimer();
                        return null;
                    }
                }
        );

        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (!isVisible) return;
                seekToInt = progress;
                String temp = TimeHelper.getSeconds(progress);
                currentTime.setText(temp);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                if (!isVisible) return;
                setPlayPauseImage("buffering", false);
                isSeeking = true;
                stopTimer();
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                if (!isVisible) return;
                videoFns.seekTo(seekToInt);
                isSeeking = false;
                restartTimer();
            }
        });
    }

    public int setDeviceBrightness(double height, float distance, MotionEvent me2) {
        double meDistance = Math.abs(me2.getY() - startLocation);
        startLocation = me2.getY();
        double changedVal = (meDistance / height) * 100;

        if (distance < 0) {
            changedVal = -changedVal;
        }

        if ((lastBrightnessProgress + changedVal) >= 100.0) {
            lastBrightnessProgress = 100.0;
        } else if ((lastBrightnessProgress + changedVal) <= 0.0) {
            lastBrightnessProgress = 0.0;
        } else {
            lastBrightnessProgress += changedVal;
        }

        layoutParams.screenBrightness = (float) (lastBrightnessProgress / 100.0);

        if (layoutParams.screenBrightness > 1.0f) {
            layoutParams.screenBrightness = 1.0f;
        } else if (layoutParams.screenBrightness < 0.1f) {
            layoutParams.screenBrightness = 0.1f;
        }

        window.setAttributes(layoutParams);

        return (int) lastBrightnessProgress;
    }

    public int setDeviceVolume(double height, float distance, MotionEvent me2) {
        skipVolListener = true;

        double meDistance = Math.abs(me2.getY() - startLocation);

        startLocation = me2.getY();

        double changedVal = (meDistance / height) * 100;

        if (distance < 0) {
            changedVal = -changedVal;
        }

        if ((lastVolProgress + changedVal) >= 100.0) {
            lastVolProgress = 100.0;
        } else if ((lastVolProgress + changedVal) <= 0.0) {
            lastVolProgress = 0.0;
        } else {
            lastVolProgress += changedVal;
        }

        int newVolume = (int) (lastVolProgress / 100.0 * maxVolume);
        audio.setStreamVolume(AudioManager.STREAM_MUSIC, newVolume, 0);

        return (int) lastVolProgress;
    }

    public int getNewProgress(double yPos, double containerHeight) {
        int result = (int) (((containerHeight - yPos) / containerHeight) * 100.0);
        return result;
    }

    public void setSeekBarProgress() {
        //Brightness Seekbar
        if (lastBrightnessProgress < 1) {
            window = myActivity.getWindow();
            layoutParams = window.getAttributes();

            int curDevBrightness = android.provider.Settings.System.getInt(cResolver, android.provider.Settings.System.SCREEN_BRIGHTNESS, -1);

            lastBrightnessProgress = ((curDevBrightness / 255.0) * 100.0);
        }

//        if (brightnessContainer.getHeight() > 300){
//            int maxHeight = (int) (screenLayout.getHeight() * 0.5);
//
//            brightnessContainer.getLayoutParams().height = maxHeight;
//            volumeContainer.getLayoutParams().height = maxHeight;
//        } else {
//            ViewGroup.LayoutParams params = brightnessContainer.getLayoutParams();
//            params.height = ViewGroup.LayoutParams.FILL_PARENT;
//
//            brightnessContainer.setLayoutParams(params);
//            volumeContainer.setLayoutParams(params);
//        }

        //Volume Seekbar
        if (lastVolProgress < 1) {
            double maxVolDouble = (double) maxVolume;
            int currentVol = audio.getStreamVolume(AudioManager.STREAM_MUSIC);
            lastVolProgress = ((currentVol / maxVolDouble) * 100.0);
        }

        brightnessSeekBar.setProgress((int) lastBrightnessProgress);
        volumeSeekBar.setProgress((int) lastVolProgress);
    }
}
