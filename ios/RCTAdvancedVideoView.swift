//
//  ControlsView.swift
//  Hit88
//
//  Created by Sim Hann Zern  on 15/06/2020.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

@available(iOS 10.0, *)
class RCTAdvancedVideoView: UIView {
    //AV Player Related
    var videoUrlString: String?
    var videoUrl: URL?
    var videoInit: Bool = false
    var safeAreaSet: Bool = false
    var isVideoLive: Bool = false
    var videoType: String = ""
//    var vlcPlayer:CustomVLCPlayer?
    var vlcContainer:UIView?
    var vlcBoundsSet: Bool = false
    var vlcSourceSet: Bool = false
    var vlcStartedAlready: Bool = false
    var avPlayer:CustomAVPlayer?
    var avPlayerLayer:AVPlayerLayer?
    var avPlayerController:AVPlayerViewController?
    var avPlayerStarted: Bool = false
    var avBoundsSet: Bool = false
    
    //Controls Related
    var controlsLayer:UIView?
    var canSwipeToSeek: Bool = true
    var seekDetails: SeekDetails!
    var playPauseButton: PlayPauseButton!
    var brightnessControls: BrightnessControls!
    var volumeControls: VolumeControls!
    var topControls: TopControls!
    var bottomControls: BottomControls!
    var loadingSpinner: UIActivityIndicatorView!
    
    //Swipe Gestures Related
    var showHomeIndicator:Bool = false
    var isSwiping:Bool = false
    var startLocation: CGPoint = CGPoint.init(x: 0, y: 0)
    var swipeThreshold: CGFloat = 50.0
    var swipeDistanceForStart: CGFloat = 0.0
    var currSwipeLocation: NSString = "vol"
    
    //JSSwift Callback Related
    @objc var onFullscreen: RCTDirectEventBlock?
    @objc var onBackPressed: RCTDirectEventBlock?
    @objc var onLikePressed: RCTDirectEventBlock?
    @objc var onSharePressed: RCTDirectEventBlock?
    @objc var onDownloadPressed: RCTDirectEventBlock?
    @objc var onLivePressed: RCTDirectEventBlock?
    @objc var onControlsShow: RCTDirectEventBlock?
    @objc var onControlsHide: RCTDirectEventBlock?
    
    var timerToHideControls: Timer?
    var tapTimes = 0
    var timerForTapAction: Timer?
    var timerToRestartListener: Timer?
    var timerToSetSource: Timer?
    
    var isSpinning:Bool = false
    
    @objc var isVisible: Bool = false  {
        didSet {
            isVisible ? controlsShown() : controlsHidden()
            isVisible ? restartTimer() : cancelTimer()
            //            controlsLayer?.backgroundColor = isVisible ? UIColor(red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(0.75)) : .none
            //            isVisible ? playPauseButton?.showUI() : playPauseButton?.hideUI()
            isVisible ? topControls?.showUI() : topControls?.hideUI()
            isVisible ? bottomControls?.showUI() : bottomControls?.hideUI()
            isVisible ? brightnessControls?.showUI() : brightnessControls?.hideUI()
            isVisible ? volumeControls?.showUI() : volumeControls?.hideUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        
        videoUrl = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")
        setupVideoUI()
        setupControlsUI()
        setupGestureListener()
    }
    
    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        tapTimes += 1
        
        if (timerForTapAction == nil){
            timerForTapAction = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { timer in
                self.determineTapCount()
            }
        }
    }
    
    func determineTapCount() {
        if (tapTimes > 1){
            if (!isVideoLive) {
                if let player = avPlayer {
                    if player.timeControlStatus == .playing {
                        avPlayer?.pause()
                        playPauseButton.showUI("pause")
                    }
                    else {
                        volumeControls?.isSwiping = true
                        avPlayer?.play()
                        playPauseButton.showUI("play")
                        
                        timerToRestartListener?.invalidate()
                        timerToRestartListener = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                            self.volumeControls?.isSwiping = false
                        }
                    }
                }
                
            }
        } else {
            isVisible = !isVisible as Bool
        }
        timerForTapAction?.invalidate()
        timerForTapAction = nil
        tapTimes = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been implemented")
    }
    
    func setupVideoUI() {
        avPlayer = CustomAVPlayer(url: videoUrl!)
        avPlayerController = AVPlayerViewController()
        avPlayerController?.player = avPlayer
        avPlayerController?.showsPlaybackControls = false
        
        self.addSubview((avPlayerController?.view)!)
    }
    
    func setupControlsUI() {
        controlsLayer = UIView()
        
        seekDetails = SeekDetails()
        controlsLayer?.addSubview(seekDetails)
        seekDetails.setup(in: controlsLayer!)
        
        brightnessControls = BrightnessControls()
        controlsLayer?.addSubview(brightnessControls!)
        brightnessControls.setup(in: controlsLayer!)
        
        volumeControls = VolumeControls()
        controlsLayer?.addSubview(volumeControls!)
        volumeControls.setup(in: controlsLayer!)
        
        topControls = TopControls()
        controlsLayer?.addSubview(topControls!)
        topControls.setup(in: controlsLayer!)
        
        bottomControls = BottomControls()
        controlsLayer?.addSubview(bottomControls!)
        bottomControls.setup(in: controlsLayer!)
        
        self.addSubview(controlsLayer!)
    }
    
    override func layoutSubviews() {
        if (loadingSpinner == nil) {
            loadingSpinner = UIActivityIndicatorView(style: .whiteLarge)
            loadingSpinner.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
            
            self.addSubview(loadingSpinner!)
            loadingSpinner!.startAnimating()
            loadingSpinner!.hidesWhenStopped = true
            isSpinning = true
        } else {
            loadingSpinner.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        }
        
        avPlayer?.mainClass = self
        avPlayerController?.view.frame = self.bounds;
        
        controlsLayer?.frame = self.bounds
        controlsLayer?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(_:))))
        
        brightnessControls?.mainClass = self
        brightnessControls?.parentWidth = Int(self.bounds.width)
        brightnessControls?.parentHeight = Int(self.bounds.height)
        brightnessControls?.updatePosition()
        
        volumeControls?.mainClass = self
        volumeControls?.parentWidth = Int(self.bounds.width)
        volumeControls?.parentHeight = Int(self.bounds.height)
        volumeControls?.updatePosition()
        
        topControls?.mainClass = self
        topControls?.parentWidth = Int(self.bounds.width)
        topControls?.updatePosition()
        
        bottomControls?.mainClass = self
        bottomControls?.parentWidth = Int(self.bounds.width)
        bottomControls?.updatePosition()
        
        seekDetails?.mainClass = self
        seekDetails?.parentWidth = Int(self.bounds.width)
        seekDetails?.parentHeight = Int(self.bounds.height)
        seekDetails?.updatePosition()
        
        avBoundsSet = true
    }
    
    func setupGestureListener() {
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(swipeGestureTriggered(gesture:)))
        self.addGestureRecognizer(swipeGesture)
    }
    
    @objc func swipeGestureTriggered(gesture: UIPanGestureRecognizer) {
        let touchedLocation = gesture.location(in: self)
        if (!canSwipeToSeek || !checkAreaSwipable(touchedLocation)) { return }
        
        if (gesture.state == .began) {
            swipeDistanceForStart = 0.0
            startLocation = gesture.location(in: self)
            currSwipeLocation = checkVolOrBrtArea(startLocation)
        } else if (gesture.state == .ended) {
            isSwiping = false
            seekDetails?.done()
            swipeDistanceForStart = 0.0
            restartTimer()
            
            timerToRestartListener?.invalidate()
            timerToRestartListener = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                self.volumeControls?.isSwiping = false
            }
        } else {
            let currLocation = gesture.location(in: self)
            let distanceX = currLocation.x - startLocation.x
            var distanceY = currLocation.y - startLocation.y
            startLocation = currLocation
            
            let velocity = gesture.velocity(in: self)
            
            if (abs(velocity.x) > abs(velocity.y)) {
                //horizontal swipe
                if (!isSwiping && swipeDistanceForStart < swipeThreshold && !isVideoLive && avPlayerStarted) {
                    swipeDistanceForStart += abs(distanceX)
                } else if (swipeDistanceForStart >= swipeThreshold) {
                    isSwiping = true
                    if (!seekDetails.started) { seekDetails.start() }
                    if (distanceX != 0){
                        if (distanceX > 0){
                            let seekValue = abs(Int(distanceX/2.5))
                            
                            if (seekValue > 0) {
                                seekDetails?.addSeekAmount(seekValue)
                            }
                        }
                        else {
                            let seekValue = abs(Int(distanceX/2.5))
                            
                            if (seekValue > 0) {
                                seekDetails?.minusSeekAmount(seekValue)
                            }
                        }
                    }
                }
            } else {
                if (isSwiping) {return}
                //vertical swipe
                swipeDistanceForStart = 0.0
                if (distanceY != 0){
                    restartTimer()
                    if (distanceY < 0) { distanceY = abs(distanceY) }
                    else { distanceY = -distanceY }
                    
                    if (currSwipeLocation == "volume"){
                        volumeControls?.swipeVolume(distanceY)
                    } else {
                        brightnessControls?.swipeBrightness(distanceY)
                    }
                }
            }
        }
    }
    
    /// CALLBACK TO JS SIDE
    func toggleJSFullscreen() {
        restartTimer()
        
        if (onFullscreen != nil) {
            onFullscreen!(["dummy": true])
        }
    }
    
    func controlsShown() {
        if (onControlsShow != nil) {
            onControlsShow!(["dummy": true])
        }
    }
    
    func controlsHidden() {
        if (onControlsHide != nil) {
            onControlsHide!(["dummy": true])
        }
    }
    
    func btnPressed(btnTag: Int) {
        switch btnTag {
        case 0:
            if (onBackPressed != nil) {
                onBackPressed!(["dummy": true])
            }
            break
        case 1:
            if (onLikePressed != nil) {
                onLikePressed!(["dummy": true])
            }
            break
        case 2:
            if (onSharePressed != nil) {
                avPlayer?.pause()
                onSharePressed!(["dummy": true])
            }
            break
        case 3:
            if (onDownloadPressed != nil) {
                avPlayer?.pause()
                onDownloadPressed!(["dummy": true])
            }
            break
        case 4:
            showBuffering()
            setVideoSource()
        default:
            break
        }
        
        restartTimer()
    }
    
    func pauseAvPlayer() {
        avPlayer?.pause()
    }
    
    func playAvPlayer() {
        avPlayer?.play()
    }
    
    func muteVideoPlayer() {
        DispatchQueue.main.async {
            self.volumeControls?.mute()
        }
    }
    
    func unmuteVideoPlayer() {
        DispatchQueue.main.async {
            self.volumeControls?.unmute()
        }
    }
    
    func killAvPlayer() {
        if (avPlayer != nil) {
            DispatchQueue.main.async() {
                self.volumeControls?.unmute()
                self.avPlayer?.pause()
                self.avPlayerLayer?.player = nil
                self.volumeControls?.removeVolumeMask()
            }
        }
    }
    
    func fakeKillAvPlayer() {
        if (avPlayer != nil) {
            volumeControls?.unmute()
            self.avPlayer?.pause()
        }
    }
    
    func showSystemHUD() {
        volumeControls?.removeVolumeMask()
    }
    
    func showBuffering() {
        isSpinning = true
        loadingSpinner?.startAnimating()
    }
    
    func hideBuffering() {
        isSpinning = false
        loadingSpinner?.stopAnimating()
    }
    
    //SET JS PROPS//
    @objc func setIsFullscreen(_ val:Bool) {
        bottomControls?.changeZoomBtnImage(val)
        topControls?.changeBackBtnStatus(val)
    }
    
    @objc func setSwipeToSeek(_ val:Bool) {
        canSwipeToSeek = val
    }
    
    @objc func setSource(_ val:String) {
        avPlayerStarted = false
        if (val.count < 1) { return }
        showBuffering()
        timerToSetSource?.invalidate()
        videoUrlString = val
        
        if (checkIsUrl(val)){
            videoUrl = URL(string: val)
        } else {
            videoUrl = URL(fileURLWithPath: val)
        }
        
        if (!avBoundsSet) {
            timerToSetSource = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                self.setVideoSource()
            }
            return
        } else {
            self.setVideoSource()
        }
    }
    
    @objc func setSeekBarColor(_ val:String) {
        bottomControls?.setTrackColor(val)
    }
    
    @objc func setTitle(_ val: String) {
        topControls?.titleTextSet = false
        topControls?.setTitleText(val)
    }
    
    @objc func setIsLiked(_ val: Bool) {
        topControls?.isLikeSet = false
        topControls?.setIsLike(val)
    }
    
    @objc func setShowLikeButton(_ val: Bool) {
        topControls?.showLikeBtn = val
    }
    
    @objc func setShowShareButton(_ val: Bool) {
        topControls?.showShareBtn = val
    }
    
    @objc func setShowDownloadButton(_ val: Bool) {
        topControls?.showDownloadBtn = val
    }
    
    @objc func setShowFullscreenControls(_ val: Bool) {
        if (topControls != nil){
            
        }
        topControls?.showBackBtn = val
        bottomControls?.showZoomButton = val
        topControls?.changeBackBtnStatus(val)
        topControls?.changeBackBtnStatus(!val)
        bottomControls?.changeZoomBtnImage(val)
        bottomControls?.changeZoomBtnImage(!val)
    }
    
    @objc func setShowHomeIndicator(_ val: Bool) {
        showHomeIndicator = val
        bottomControls?.mainClass = self
        bottomControls?.updatePosition()
    }
    
    //// / / / / / / / / / /
    func setVideoSource() {
        timerToSetSource?.invalidate()
        fakeKillAvPlayer()
        isVisible = false
        
        if (!avBoundsSet) {
            timerToSetSource = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
                self.setVideoSource()
            }
        } else {
            avPlayer = CustomAVPlayer(url: videoUrl!)
            avPlayerController?.player = avPlayer
            
            playPauseButton = PlayPauseButton()
            
            playPauseButton.avPlayer = avPlayer!
            controlsLayer?.addSubview(playPauseButton!)
            playPauseButton.setup(in: controlsLayer!)
            playPauseButton.mainClass = self
            
            seekDetails?.avPlayer = avPlayer!
            bottomControls.avPlayer = avPlayer!
            
            volumeControls?.isSwiping = true
            avPlayer!.play()
            
            videoType = CustomHelper.getStreamType(videoUrlString!)
            avPlayerStarted = true
            
            if videoUrlString!.contains("rtmp") || videoUrlString!.contains("m3u8"){
                isVideoLive = true
                topControls?.showHideRefreshButton(true)
                bottomControls?.switchControls("live")
            } else {
                isVideoLive = false
                topControls?.showHideRefreshButton(false)
                bottomControls?.switchControls("normal")
            }
            
            vlcSourceSet = true
            
            self.bringSubviewToFront(controlsLayer!)
        }
    }
    
    func checkIsUrl(_ val:String) -> Bool {
        return val.matches("((https|http|rtmp)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+")
    }
    
    func checkAreaSwipable(_ location:CGPoint) -> Bool {
        if (!self.isVisible) {return true}
        
        let untouchable = bottomControls!.frame.height + 5
        let touchedAt = self.frame.height - location.y
        
        if (touchedAt > untouchable) { return true }
        return false
    }
    
    func checkVolOrBrtArea(_ location:CGPoint) -> NSString {
        let xPoint:CGFloat = location.x
        let fullWidth:CGFloat = self.frame.size.width
        
        if (xPoint > fullWidth/2){
            return "volume"
        } else {
            return "brightness"
        }
    }
    
    func restartTimer() {
        cancelTimer()
        timerToHideControls = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
            self.isVisible = false
        }
    }
    
    func cancelTimer() {
        timerToHideControls?.invalidate()
    }
    
    @objc func toggleIsVisible() {
        isVisible = !isVisible as Bool
    }
}

extension StringProtocol {
    func matches<T>(_ pattern: T) -> Bool where T: StringProtocol {
        return self.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

extension UIView {
    ///Constraints a view to its superview
    func constraintToSuperView() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
    }
    
    ///Constraints a view to its superview safe area
    func constraintToSafeArea() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        
        topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor).isActive = true
        rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor).isActive = true
    }
}
