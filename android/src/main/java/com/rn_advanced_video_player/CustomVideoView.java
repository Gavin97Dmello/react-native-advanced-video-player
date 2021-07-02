package com.rn_advanced_video_player;

import android.content.Context;
import android.os.Handler;
import android.util.AttributeSet;
import android.widget.VideoView;

public class CustomVideoView extends VideoView {
    private int mVideoWidth;
    private int mVideoHeight;

    public double oriWidth;
    public double oriHeight;

    public int lastWidth;
    public int lastHeight;

    public AdvancedVideoView avv;

    public CustomVideoView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public CustomVideoView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    public CustomVideoView(Context context) {
        super(context);
    }

    public void resizeVideo() {
        requestLayout();
        invalidate();
    }

    @Override
    public void onMeasure(final int widthMeasureSpec, final int heightMeasureSpec) {
        int sWidth = getDefaultSize(mVideoWidth, widthMeasureSpec);
        int sHeight = getDefaultSize(mVideoHeight, heightMeasureSpec);

        int nWidth = sWidth;
        int nHeight = sHeight;

        if (lastWidth != avv.containerWidth || lastHeight != avv.containerHeight) {
            lastWidth = avv.containerWidth;
            lastHeight = avv.containerHeight;
        } else {
            requestLayout();
            invalidate();
        }

        if (oriWidth > 0 && oriHeight > 0) {
            nWidth = avv.containerWidth;
            nHeight = (int) (nWidth / oriWidth);

            if (nHeight > avv.containerHeight) {
                nHeight = avv.containerHeight;
                nWidth = (int) (nHeight * oriWidth);
            }
        }

        setMeasuredDimension(nWidth, nHeight);
    }
}
