package com.rn_advanced_video_player;

import android.content.Context;
import android.view.GestureDetector;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;

public class OnSwipeTouchListener implements OnTouchListener {

    private final GestureDetector gestureDetector;

    public OnSwipeTouchListener (Context ctx){
        gestureDetector = new GestureDetector(ctx, new GestureListener());
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        int action = event.getActionMasked();
        if (action == MotionEvent.ACTION_UP) {
            onStopSwipe();
        }
        return gestureDetector.onTouchEvent(event);
    }

    private final class GestureListener extends SimpleOnGestureListener {

        private static final int SWIPE_THRESHOLD = 100;
        private static final int SWIPE_VELOCITY_THRESHOLD = 100;

        @Override
        public boolean onDown(MotionEvent e) {
            onStartSwipe(e);
            return true;
        }

        @Override
        public boolean onDoubleTap(MotionEvent e) {
            onDoubleTapped();
            return true;
        }

        @Override
        public boolean onScroll(MotionEvent event1, MotionEvent event2, float distanceX,
                                float distanceY) {
            if (distanceX > 0){
                onSwipeLeft(Math.abs(distanceX));
            } else if (distanceX < 0){
                onSwipeRight(Math.abs(distanceX));
            } else if (distanceY > 0) {
                onSwipeUp(Math.abs(distanceY), event1, event2);
            } else if (distanceY < 0) {
                onSwipeDown(-Math.abs(distanceY), event1, event2);
            }
            return true;
        }

        @Override
        public boolean onSingleTapConfirmed(MotionEvent e) {
            onClick();
            return true;
        }
    }

    public void onSwipeRight(float distance) {
    }

    public void onSwipeLeft(float distance) {
    }

    public void onStartSwipe(MotionEvent me) {}

    public void onStopSwipe() {}

    public void onSwipeUp(float distance, MotionEvent me1, MotionEvent me2) {
    }

    public void onSwipeDown(float distance, MotionEvent me1, MotionEvent me2) {
    }

    public void onClick() {}

    public void onDoubleTapped() {}
}
