package org.cocos2d;

import android.app.Activity;

import android.os.Bundle;
import com.apportable.RuntimeService;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.os.MessageQueue;
import android.os.MessageQueue.IdleHandler;
import android.view.KeyEvent;
import android.view.SurfaceView;
import android.view.SurfaceHolder;
import android.view.WindowManager;
import java.util.TimerTask;

import android.util.Log;

public class CCActivity extends Activity implements SurfaceHolder.Callback, Runnable {
    private Handler mHandler;

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        new RuntimeService(this).loadLibraries();
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        run();
    }
    
    public native void runLoop();
    public native void run();

    public native void onDestroy();
    public native void onResume();
    public native void onPause();
    
    public native void onLowMemory();
    
    public native void surfaceCreated(SurfaceHolder holder);
    public native void surfaceChanged(SurfaceHolder holder, int format, int width, int height);
    public native void surfaceDestroyed(SurfaceHolder holder);
    
    public native boolean onKeyDown(int keyCode, KeyEvent event);
    public native boolean onKeyUp(int keyCode, KeyEvent event);
}

