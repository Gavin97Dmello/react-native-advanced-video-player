package com.rn_advanced_video_player;

import android.graphics.Color;

public class ColorHelper {
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
}
