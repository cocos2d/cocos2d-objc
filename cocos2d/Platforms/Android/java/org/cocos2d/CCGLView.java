package org.cocos2d;

import android.content.Context;
import android.view.SurfaceView;
import android.view.MotionEvent;

import android.util.Log;

public class CCGLView extends SurfaceView {
    public CCGLView(Context ctx) {
        super(ctx);
    }
    
    public native boolean onTouchEvent(MotionEvent e);
}