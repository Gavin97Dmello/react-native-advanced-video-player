package com.rn_advanced_video_player;

import android.app.Activity;
import android.content.Context;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Handler;
import android.view.SurfaceHolder;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.MediaController;
import android.widget.RelativeLayout;

import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.ext.rtmp.RtmpDataSourceFactory;
import com.google.android.exoplayer2.source.ExtractorMediaSource;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.trackselection.AdaptiveTrackSelection;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.trackselection.TrackSelection;
import com.google.android.exoplayer2.trackselection.TrackSelector;
import com.google.android.exoplayer2.ui.PlayerView;
import com.google.android.exoplayer2.upstream.BandwidthMeter;
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter;

import java.io.IOException;
import java.util.HashMap;

import wseemann.media.FFmpegMediaMetadataRetriever;

public class VideoPlayer extends Activity implements SurfaceHolder.Callback {
    //Player variables
    public Window window;
    public MediaPlayer mPlayer;
    public SurfaceHolder surfaceHolder;
    public RelativeLayout videoContainer;
    public CustomVideoView videoView;
    public PlayerView exoView;
    public SimpleExoPlayer exoPlayer;
    public VideoControls videoControls;
    private Handler handler = new Handler();
    private Handler seekToLiveHandler = new Handler();
    private Handler waitForSurfaceExistHandler = new Handler();

    MediaSource mediaSource;

    public Context myContext;
    public Activity myActivity;
    public AdvancedVideoView.SpecialFunctions specialFns;
    public FrameLayout screenLayout;

    //Value variables
    public boolean surfaceExist = false;
    public boolean doneInit = false;
    public boolean mPlayerReleased = false;
    public String videoUrl;
    public Uri videoUri;
    public Boolean isPlaying = true;
    public Boolean isBuffering = true;
    public int currentTime = 0;
    public int videoLength = 0;
    public boolean canSeek = false;
    public boolean isLiveStream = false;
    public String currentPlayer = "videoView";

    public VideoPlayer(Context context, Activity activity, FrameLayout frameLayout, AdvancedVideoView.SpecialFunctions specialFunctions) {
        myContext = context;
        myActivity = activity;
        screenLayout = frameLayout;
        specialFns = specialFunctions;
        window = activity.getWindow();
    }

    public void initializePlayer() {
        new MyAsyncTask().execute();
    }

    public void initPlayer2() {
        System.out.println("AFTER KILL");
        isLiveStream = false;

        surfaceHolder = videoView.getHolder();
        surfaceHolder.addCallback(this);

        if (!doneInit) {
            doneInit = true;
            initExoPlayer();

            mPlayer = new MediaPlayer();

            MediaController mediaController = new MediaController(myContext);
            mediaController.setVisibility(View.GONE);
            mediaController.setAnchorView(videoView);

            //Initialize controls
            videoControls = new VideoControls(myContext, myActivity, screenLayout, new VideoFunctions());
            videoControls.initializeControls();
            toggleSeekBarStatus(false);
        }

        runOnUiThread(new Runnable() {
            public void run() {
                isBuffering = true;
                videoControls.setPlayPauseImage("buffering", false);
            }
        });

        String streamType = MyHelper.getStreamType(videoUrl);

        videoUri = Uri.parse(videoUrl);

        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        toggleSeekBarStatus(false);

        if (streamType == "rtmp") {
            isLiveStream = true;
            currentPlayer = "exoPlayer";
            switchPlayers();

            RtmpDataSourceFactory rtmpDataSourceFactory = new RtmpDataSourceFactory();

            mediaSource = null;
            mediaSource = new ExtractorMediaSource.Factory(rtmpDataSourceFactory)
                    .createMediaSource(videoUri);

            try {
                exoPlayer.prepare(mediaSource);
                continueInitialization();
            } catch (Exception e) {
                System.out.println("PREPARE EXO PLAYER EXCEPTION");
                e.printStackTrace();
            }
        } else {
            currentPlayer = "videoView";
            if (streamType == "live") {
                isLiveStream = true;
            }

            switchPlayers();
            setMpMediaSource(videoUrl);
        }

        videoControls.switchControls(streamType);
    }

    public void setMpMediaSource(final String videoUrl) {
        if (waitForSurfaceExistHandler != null) {
            waitForSurfaceExistHandler.removeCallbacksAndMessages(null);
        }
        if (surfaceExist && mPlayer != null) {
            try {
                String streamType = MyHelper.getStreamType(videoUrl);
                if (!streamType.equals("live")) {
                    new Thread(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                FFmpegMediaMetadataRetriever mmr = new FFmpegMediaMetadataRetriever();
                                mmr.setDataSource(videoUrl);
                                HashMap<String, String> mtData = mmr.getMetadata().getAll();

//                    System.out.println("META width " + mtData.get("video_width") + " height " + mtData.get("video_height"));
                                videoView.oriWidth = Double.valueOf(mtData.get("video_width")) / Double.valueOf(mtData.get("video_height"));
                                videoView.oriHeight = 1;
//                    System.out.println("RATIO Width:Height = " + videoView.oriWidth + ":1");

                                mmr.release();

                                videoView.requestLayout();
                                videoView.invalidate();
                            } catch (RuntimeException e) {
                                System.out.println("CALC META DATA EXCEPTION");
                                e.printStackTrace();
                            }
                        }
                    }).start();
                }

                mPlayer.reset();
                mPlayer.setDataSource(videoUrl);
                System.out.println("DONE SET DATA SOURCE MPLAYER");
                mPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                    @Override
                    public void onPrepared(MediaPlayer mp) {
                        System.out.println("PREPARED CONTINUE INIT");
                        continueInitialization();
                    }
                });
                mPlayer.prepareAsync();
            } catch (Exception e) {
                System.out.println("SET MPMEDIASOURCE EXCEPTION");
                e.printStackTrace();
            }
        } else {
            waitForSurfaceExistHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    setMpMediaSource(videoUrl);
                }
            }, 100);
        }
    }

    public void continueInitialization() {
        // Prepare the player with the source.
        unmutePlayer();
        play(false);

        if (handler != null) {
            handler.removeCallbacksAndMessages(null);
        }
        handler = new Handler();
        updateProgressBar();
        toggleSeekBarStatus(true);
    }

    public void initExoPlayer() {
        // Create a default TrackSelector
        BandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();
        TrackSelection.Factory videoTrackSelectionFactory =
                new AdaptiveTrackSelection.Factory(bandwidthMeter);
        TrackSelector trackSelector =
                new DefaultTrackSelector(videoTrackSelectionFactory);

        //Initialize the player
        exoPlayer = ExoPlayerFactory.newSimpleInstance(myContext, trackSelector);

        //Initialize simpleExoPlayerView
        exoView.setPlayer(exoPlayer);
        exoView.setUseController(false);
    }

    public void switchPlayers() {
        runOnUiThread(new Runnable() {
            public void run() {
                if (currentPlayer == "videoView") {
                    if (exoView.getParent() != null && videoContainer.getChildAt(0).getTag() != null && videoContainer.getChildAt(0).getTag().equals("exoPlayer")) {
                        videoContainer.removeViewAt(0);
                    }
                    if (videoView.getParent() == null) {
                        videoContainer.addView(videoView, 0);
                    }
                } else {
                    if (videoView.getParent() != null && videoContainer.getChildAt(0).getTag() != null && videoContainer.getChildAt(0).getTag().equals("videoView")) {
                        videoContainer.removeViewAt(0);
                    }
                    if (exoView.getParent() == null) {
                        videoContainer.addView(exoView, 0);
                    }
                }
            }
        });
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        try {
            mPlayer.setDisplay(holder);
            surfaceExist = true;
        } catch (Exception e) {
            System.out.println("SURFACE CREATED ERROR");
            e.printStackTrace();
        }
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        surfaceExist = false;
    }


    public class VideoFunctions {
        public void togglePlayStatus() {
            if (isPlaying) {
                pause(true);
            } else {
                play(true);
            }
        }

        public void seekTo(int value) {
            seekToPosition(value);
        }

        public Boolean isBuffering() {
            return isBuffering;
        }

        //PASS TO PARENT (ADVANCEDVIDEOVIEW)
        public void toggleFullscreen() {
            specialFns.toggleFullscreen();
        }

        public void backPressed() {
            specialFns.backPressed();
        }

        public void likePressed() {
            specialFns.likePressed();
        }

        public void sharePressed() {
            specialFns.sharePressed();
        }

        public void downloadPressed() {
            specialFns.downloadPressed();
        }

        public void seekToLivePosition() {
            pause(false);

            if (seekToLiveHandler != null) {
                seekToLiveHandler.removeCallbacksAndMessages(null);
            }
            if (handler != null) {
                handler.removeCallbacksAndMessages(null);
            }

            runOnUiThread(new Runnable() {
                public void run() {
                    isBuffering = true;
                    videoControls.setPlayPauseImage("buffering", false);
                }
            });

            specialFns.refreshPressed();

            seekToLiveHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    initializePlayer();
                }
            }, 1000);
        }

        public void controlsShown() {
            specialFns.controlsShown();
        }

        public void controlsHidden() {
            specialFns.controlsHidden();
        }
    }

    public void seekToPosition(int value) {
        if (mPlayer != null && !mPlayerReleased && canSeek) {
            try {
                if (isPlaying) {
                    videoControls.setPlayPauseImage("buffering", false);
                    isBuffering = true;
                }
                mPlayer.seekTo(value * 1000);
            } catch (Exception e) {
                System.out.println("SEEK TO POSITION ERROR");
                e.printStackTrace();
            }
        }
    }

    public void play(Boolean showIcon) {
        if (currentPlayer.equals("videoView")) {
            try {
                if (mPlayer != null && !mPlayerReleased && !mPlayer.isPlaying()) {
                    mPlayer.start();
                    isPlaying = true;
                    window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                }
            } catch (Exception e) {
                System.out.println("PLAY MPLAYER ERROR");
                e.printStackTrace();
            }
        } else if (exoPlayer != null) {
            isPlaying = true;
            exoPlayer.setPlayWhenReady(true);
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
        videoControls.setPlayPauseImage("play", showIcon);
    }

    public void pause(Boolean showIcon) {
        if (currentPlayer.equals("videoView")) {
            try {
                if (mPlayer != null && !mPlayerReleased && mPlayer.isPlaying()) {
                    mPlayer.pause();
                    isPlaying = false;
                    window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                }
            } catch (Exception e) {
                System.out.println("PAUSE MPLAYER ERROR");
                e.printStackTrace();
            }
        } else if (exoPlayer != null) {
            isPlaying = false;
            exoPlayer.setPlayWhenReady(false);
            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }

        videoControls.setPlayPauseImage("pause", showIcon);
    }

    public void mutePlayer() {
        if (exoPlayer != null){
            exoPlayer.setVolume(0f);
        }
        if (mPlayer != null && !mPlayerReleased) {
            try {
                mPlayer.setVolume(0, 0);
            } catch (Exception e) {
                System.out.println("MPLAYER MUTE ERROR");
                e.printStackTrace();
            }
        }
    }

    public void unmutePlayer() {
        if (exoPlayer != null){
            exoPlayer.setVolume(1f);
        }
        if (mPlayer != null && !mPlayerReleased) {
            try {
                mPlayer.setVolume(1, 1);
            } catch (Exception e) {
                System.out.println("MPLAYER UNMUTE ERROR");
            }
        }
    }

    private void updateProgressBar() {
        if (handler == null) return;

        long duration = 0;
        long position = 0;

        if (currentPlayer == "videoView" && videoView != null) {
            if (mPlayer == null || mPlayerReleased) return;
            duration = mPlayer.getDuration();
            position = mPlayer.getCurrentPosition();
        } else if (currentPlayer == "exoPlayer") {
            if (exoPlayer == null) return;
            duration = exoPlayer.getDuration();
            position = mPlayer.getCurrentPosition();
        }

        if (currentPlayer == "exoPlayer" && exoPlayer.getPlaybackState() == Player.STATE_BUFFERING) {
            isBuffering = true;
            videoControls.setPlayPauseImage("buffering", false);
        } else if (currentPlayer == "exoPlayer" && isPlaying && isBuffering) {
            System.out.println("here");
            isBuffering = false;
            if (isPlaying) play(false);
            else pause(false);
        } else if (isPlaying && isBuffering && currentTime != position / 1000) {
            System.out.println("here 2");
            isBuffering = false;
            if (isPlaying) play(false);
            else pause(false);
        }

        currentTime = (int) position / 1000;
        videoLength = (int) duration / 1000;
        videoControls.updateProgress(position, duration);

        if (handler == null) {
            return;
        }
        handler.postDelayed(updateProgressAction, 1000);
    }

    private final Runnable updateProgressAction = new Runnable() {
        @Override
        public void run() {
            updateProgressBar();
        }
    };

    public void killVideoPlayer(boolean realKill) {
        if (mPlayer != null && !mPlayerReleased && exoView != null && exoPlayer != null && doneInit) {

            if (handler != null) {
                handler.removeCallbacksAndMessages(null);
                handler = null;
            }

            currentTime = 0;
            videoLength = 0;

            runOnUiThread(new Runnable() {
                public void run() {
                    if (videoControls != null) {
                        videoControls.hideControls();
                        videoControls.updateProgress(currentTime, videoLength);
                    }
                }
            });

            if (!realKill) {
                runOnUiThread(new Runnable() {
                    public void run() {
                        try {
                            if (mPlayer != null) {
                                mPlayer.stop();
                                mPlayer.reset();
                                mPlayer.setOnPreparedListener(null);
                                toggleSeekBarStatus(false);
                                System.out.println("STOPPED MPLAYER");
                            }
                        } catch (Exception e) {
                            System.out.println("STOP MPLAYER ERROR");
                            e.printStackTrace();
                        }
                    }
                });
                if (surfaceHolder != null) {
                    surfaceHolder.removeCallback(this);
                }
            } else {
                if (currentPlayer.equals("videoView")) {
                    if (mPlayer != null && !mPlayerReleased) {
                        try {
                            mPlayer.release();
                            mPlayerReleased = true;
                            toggleSeekBarStatus(false);
                        } catch (Exception e) {
                            System.out.println("RELEASE MPLAYER ERROR");
                        }
                    }
                } else {
                    exoPlayer.release();
                }
            }
        }
    }

    public void toggleSeekBarStatus(boolean active) {
        if (videoControls != null && videoControls.seekBar != null){
            canSeek = active;
            videoControls.seekBar.setEnabled(active);
        }
    }

    private class MyAsyncTask extends AsyncTask<Void, Void, Void> {
        @Override
        protected Void doInBackground(Void... params) {
            killVideoPlayer(false);
            return null;
        }

        @Override
        protected void onPostExecute(Void result) {
            initPlayer2();
        }
    }
}


