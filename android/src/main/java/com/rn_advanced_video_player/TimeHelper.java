package com.rn_advanced_video_player;

public class TimeHelper {
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
}
