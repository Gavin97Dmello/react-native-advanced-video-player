//
//  Controls.swift
//  Hit88
//
//  Created by Sim Hann Zern  on 15/06/2020.
//

import Foundation

@available(iOS 10.0, *)
@objc(RCTAdvancedVideo)
class RCTAdvancedVideo: RCTViewManager {
    var playerView: RCTAdvancedVideoView!
    
    override func view() -> UIView! {
        playerView = RCTAdvancedVideoView()
        return playerView
    }
    
    @objc public func pauseAvPlayer(_ node:NSNumber) {
        playerView?.pauseAvPlayer()
    }
    
    @objc public func playAvPlayer(_ node:NSNumber) {
        playerView?.playAvPlayer()
    }
    
    @objc public func showSystemHUD(_ node:NSNumber) {
        playerView?.showSystemHUD()
    }
    
    @objc public func killAvPlayer(_ node:NSNumber) {
        playerView?.killAvPlayer()
    }
    
    @objc public func mutePlayer(_ node:NSNumber) {
        playerView?.muteVideoPlayer()
    }
    
    @objc public func unmutePlayer(_ node:NSNumber) {
        playerView?.unmuteVideoPlayer()
    }
    
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
}
