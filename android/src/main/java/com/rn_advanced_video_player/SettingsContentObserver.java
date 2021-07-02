package com.rn_advanced_video_player;

import android.content.Context;
import android.database.ContentObserver;
import android.media.AudioManager;
import android.os.Handler;
import android.os.Message;

public class SettingsContentObserver extends ContentObserver {
    int previousVolume;
    Context context;
    Handler mHandler;

    public SettingsContentObserver(Context c, Handler handler) {
        super(handler);
        context = c;
        mHandler = handler;

        AudioManager audio = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        previousVolume = audio.getStreamVolume(AudioManager.STREAM_MUSIC);
    }

    @Override
    public boolean deliverSelfNotifications() {
        return super.deliverSelfNotifications();
    }

    @Override
    public void onChange(boolean selfChange) {
        super.onChange(selfChange);

        AudioManager audio = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        int currentVolume = audio.getStreamVolume(AudioManager.STREAM_MUSIC);

        Message msg = mHandler.obtainMessage();
        msg.arg1 = currentVolume;
        mHandler.dispatchMessage(msg);
    }
}




