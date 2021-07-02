//
//  CustomAVPlayer.swift
//  AdvancedVideoPlayer
//
//  Created by Sim Hann Zern  on 01/07/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class CustomAVPlayer:AVPlayer {
    var mainClass: RCTAdvancedVideoView?
    
    override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) {
        if (self.timeControlStatus == .playing){
            DispatchQueue.main.async {
                self.mainClass?.showBuffering()
            }
        }
        
        var needPlayAfterSeek = false
        if (self.timeControlStatus == .playing){ needPlayAfterSeek = true }
        self.pause()
        
        super.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
        
//        DispatchQueue.main.async {
//            if (self.currentItem == nil) { }
//            else if (self.currentItem!.isPlaybackBufferFull || self.currentItem!.isPlaybackLikelyToKeepUp) {
//                print("hide here")
//                self.mainClass?.hideBuffering()
//            }
//        }
        
        if (needPlayAfterSeek) {
            self.play()
            self.mainClass?.bottomControls?.resetSeeking = true
        }
    }
}
