package com.invertedx.sentinelx.channel;

import android.content.Intent;

public interface ActivityResultListener {
    void onResult(Intent intent,int resultCode);
}
