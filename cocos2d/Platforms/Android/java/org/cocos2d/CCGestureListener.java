package org.cocos2d;

import android.view.GestureDetector;
import android.view.MotionEvent;

public class CCGestureListener extends GestureDetector.SimpleOnGestureListener {
    
    public CCGestureListener() {
        super();
    }
    
    @Override
    public native boolean onDoubleTap(MotionEvent e);
    
    @Override
    public native boolean onDown(MotionEvent e);
    
    @Override
    public native boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY);
    
    @Override
    public native void onLongPress(MotionEvent e);
    
    @Override
    public native boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY);
}