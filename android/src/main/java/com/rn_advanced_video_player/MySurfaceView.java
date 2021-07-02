package com.rn_advanced_video_player;

import android.content.Context;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

public class MySurfaceView extends SurfaceView implements SurfaceHolder.Callback {
    public SurfaceHolder holder;
    public boolean hasActiveHolder = false;

    public MySurfaceView(Context context) {
        super(context);
        //Initiate the Surface Holder properly
        this.holder = this.getHolder();
        this.holder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        synchronized (this) {
            hasActiveHolder = true;

            synchronized (this) {
                this.notifyAll();
            }
        }
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        synchronized (this) {
            hasActiveHolder = false;

            synchronized (this) {
                this.notifyAll();
            }
        }
    }
}
