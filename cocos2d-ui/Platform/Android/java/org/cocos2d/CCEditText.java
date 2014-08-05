package org.cocos2d;

import android.widget.EditText;
import android.util.Log;
import android.content.Context;

public class CCEditText extends EditText {
    public CCEditText (Context context) {
        super(context);
    }

    public void setTextSizeDouble(double textSize) {
        Log.d("TEXTFIELD", "setTextSizeDouble "+textSize);
        setTextSize((float)textSize);
    }
}