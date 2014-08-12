package org.cocos2d;

import android.widget.EditText;
import android.util.Log;
import android.content.Context;
import android.view.KeyEvent;

public class CCEditText extends EditText {
    public CCEditText (Context context) {
        super(context);
    }

    public void setTextSizeDouble(double textSize) {
        setTextSize((float)textSize);
    }
    
    public native boolean onKeyPreIme(int keyCode, KeyEvent event);

}