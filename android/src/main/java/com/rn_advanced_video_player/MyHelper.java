package com.rn_advanced_video_player;

import android.graphics.Color;

public class MyHelper {
    public static int getColorFromString(String colorString) {
        int redVal = 0;
        int greenVal = 0;
        int blueVal = 0;
        int alphaVal = 255;

        int finalColor = Color.WHITE;
        String tempString;

        if (colorString.contains("rgb")) {
            tempString = colorString.replace("rgb(","");
            tempString = tempString.replace(" ", "");
            tempString = tempString.replace(")", "");

            String stringArr[] = tempString.split(",");

            if (stringArr.length >= 3){
                redVal = Integer.parseInt(stringArr[0]);
                greenVal = Integer.parseInt(stringArr[1]);
                blueVal = Integer.parseInt(stringArr[2]);
            }

            if (stringArr.length == 4) {
                alphaVal = Integer.parseInt(stringArr[3]);
                alphaVal = (int) (alphaVal * 255.0f);
            }

            finalColor = Color.argb(alphaVal, redVal, greenVal, blueVal);
        } else if (colorString.contains("#")) {
            finalColor = Color.parseColor(colorString);
        }

        return finalColor;
    }

    public static String pad(int num) {
        String temp = String.valueOf(num);

        if (temp.length() < 2) {
            return "0" + temp;
        }
        return temp;
    }

    public static String getSeconds(double secs) {
        int minutes = (int) Math.floor(secs / 60);
        secs = secs % 60;
        int intSecs = (int) secs;
        int hours = (int) Math.floor(minutes / 60);
        minutes = minutes % 60;

        String hourString = pad(hours);
        String minuteString = pad(minutes);
        String secondString = pad(intSecs);

        return hourString + ":" + minuteString + ":" + secondString;
    }

    public static String getStreamType(String uri) {
        if (uri.contains("rtmp")){
            return "rtmp";
        }
        else if (uri.contains(".m3u8")){
            return "live";
        } else {
            return "normal";
        }
    }

}
