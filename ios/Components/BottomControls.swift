import Foundation
import UIKit
import AVKit
import AVFoundation

@available(iOS 10.0, *)
class BottomControls: UIStackView {
    var kvoRateContext = 0
    var parentWidth = 0
    var uiInit:Bool = false
    //    var vlcPlayer: CustomVLCPlayer?
    var avPlayer: CustomAVPlayer?
    
    //Value variables
    var videoIsLive:Bool = false
    var currentTime:Int = 0
    var videoLength:Int = 0
    var localCurrentTime:Int = 0
    var isSeeking:Bool = false
    var resetSeeking:Bool = false
    var initVolListener:Bool = false
    var initVolTimerStarted:Bool = false
    var initVolListenerTimer: Timer?
    var timeObserver:Any?
    var timerToAttachObserver: Timer?
    
    //UI variables
    var mainClass: RCTAdvancedVideoView?
    var gradientBg: CAGradientLayer?
    var stackView: UIStackView?
    var dummyText: UILabel?
    var currentTimeText: UILabel?
    var seekBarSlider: UISlider?
    var videoLengthText: UILabel?
    var zoomBtn: UIButton?
    
    var liveIndicator: UIView?
    var liveText: UILabel?
    
    //Styling variables
    var showZoomButton:Bool = true
    var trackColorSet:Bool = false
    var trackColor:UIColor = UIColor.green
    var setTrackColorTimer:Timer?
    
    //Constraint variables
    var widthCons: NSLayoutConstraint?
    var heightCons: NSLayoutConstraint?
    var svWidthCons: NSLayoutConstraint?
    var currentTimeWidthCons: NSLayoutConstraint?
    var zoomWidthCons: NSLayoutConstraint?
    var zoomHeightCons: NSLayoutConstraint?
    var liveIndWidthCons: NSLayoutConstraint?
    var liveIndHeightCons: NSLayoutConstraint?
    
    func setup(in container: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isLayoutMarginsRelativeArrangement = true
        self.axis = .horizontal
        self.spacing = 7.5
        self.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
        addGestureRecognizer(gesture)
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        self.mainClass?.restartTimer()
    }
    
    func showUI() {
        self.alpha = 1
    }
    
    func hideUI() {
        self.alpha = 0
    }
    
    func updatePosition() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = mainClass != nil ? mainClass!.showHomeIndicator ? 30 : 55 : 30
        let paddingBtm = mainClass != nil ? mainClass!.showHomeIndicator ? 5 : 30 : 35
        
        if (uiInit) {
            widthCons?.constant = CGFloat(parentWidth)
            heightCons?.constant = CGFloat(heightConstraint)
            svWidthCons?.constant = CGFloat(parentWidth)
            
            gradientBg!.removeFromSuperlayer()
            gradientBg = CAGradientLayer()
            gradientBg!.frame = CGRect(x: 0, y: 0, width: parentWidth, height: heightConstraint)
            gradientBg!.colors = [UIColor(red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(0.05)).cgColor, UIColor(red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(0.75)).cgColor]
            self.layer.insertSublayer(gradientBg!, at: 0)
            
            stackView?.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: CGFloat(paddingBtm), right: 5)
        } else {
            widthCons = self.widthAnchor.constraint(equalToConstant: CGFloat(parentWidth))
            widthCons?.isActive = true
            heightCons = self.heightAnchor.constraint(equalToConstant: CGFloat(heightConstraint))
            heightCons?.isActive = true
            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            stackView?.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: CGFloat(paddingBtm), right: 5)
        }
        
        if (!uiInit) {
            uiInit = true
            hideUI()
            setupChildUI()
            setupListeners()
            
            gradientBg = CAGradientLayer()
            gradientBg!.frame = CGRect(x: 0, y: 0, width: parentWidth, height: heightConstraint)
            gradientBg!.colors = [UIColor(red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(0.05)).cgColor, UIColor(red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(0.75)).cgColor]
            
            self.layer.insertSublayer(gradientBg!, at: 0)
        } else {
            gradientBg?.frame.size.width = CGFloat(parentWidth)
        }
    }
    
    func setupChildUI() {
        let paddingBtm = mainClass != nil ? mainClass!.showHomeIndicator ? 5 : 20 : 35
        
        stackView = UIStackView()
        stackView?.translatesAutoresizingMaskIntoConstraints = false
        stackView?.isLayoutMarginsRelativeArrangement = true
        stackView?.axis = .horizontal
        stackView?.alignment = .center
        stackView?.spacing = 7.5
        
        self.addSubview(stackView!)
        
        svWidthCons = stackView!.widthAnchor.constraint(equalToConstant: CGFloat(parentWidth))
        svWidthCons?.isActive = true
        
        stackView?.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: CGFloat(paddingBtm), right: 5)
        stackView?.addBackground(color: .clear)
        
        if (!mainClass!.isVideoLive) {
            dummyText = UILabel()
            dummyText?.text = "88:88:88"
            dummyText?.sizeToFit()
            
            currentTimeText = UILabel()
            currentTimeText?.text = "00:00:00"
            currentTimeText?.textColor = .white
            stackView?.addArrangedSubview(currentTimeText!)
            currentTimeWidthCons = currentTimeText?.widthAnchor.constraint(equalToConstant: (dummyText?.frame.size.width)!)
            currentTimeWidthCons?.isActive = true
            
            seekBarSlider = UISlider()
            seekBarSlider?.isContinuous = true
            seekBarSlider?.tintColor = UIColor.blue
            var thumbImg = UIImage(named: "thumb.png")
            thumbImg = resizeImage(image: thumbImg!, targetSize: CGSize(width: 15.0, height: 15.0))
            seekBarSlider?.setThumbImage(thumbImg, for: .normal)
            stackView?.addArrangedSubview(seekBarSlider!)
            seekBarSlider!.isUserInteractionEnabled = false
            seekBarSlider!.isEnabled = true
            
            videoLengthText = UILabel()
            videoLengthText?.text = "23:59:59"
            videoLengthText?.sizeToFit()
            videoLengthText?.textColor = .white
            stackView?.addArrangedSubview(videoLengthText!)
        }
        
        zoomBtn = UIButton()
        zoomBtn?.setImage(UIImage(named: "fullscreen.png"), for: .normal)
        zoomBtn?.addTarget(self, action: #selector(buttonTouchEvent), for: .touchUpInside)
        
        if (showZoomButton) {
            stackView?.addArrangedSubview(zoomBtn!)
            zoomWidthCons = zoomBtn?.widthAnchor.constraint(equalToConstant: 20.0)
            zoomWidthCons?.isActive = true
            zoomHeightCons = zoomBtn?.heightAnchor.constraint(equalToConstant: 20.0)
            zoomHeightCons?.isActive = true
        }
    }
    
    func switchControls(_ type:String) {
        switch (type) {
        case "live":
            if (uiInit){
                //                currentTimeWidthCons?.constant = 0
                //                currentTimeWidthCons?.isActive = false
                //                stackView?.removeArrangedSubview(currentTimeText!)
                //                seekBarSlider!.setThumbImage(UIImage(), for: .normal)
                //                stackView?.removeArrangedSubview(seekBarSlider!)
                //                stackView?.removeArrangedSubview(videoLengthText!)
                seekBarSlider?.isEnabled = false
                seekBarSlider?.alpha = 0.0
                currentTimeText?.alpha = 0.0
                videoLengthText?.alpha = 0.0
            }
            break
        default:
            seekBarSlider?.isEnabled = true
            seekBarSlider?.alpha = 1.0
            currentTimeText?.alpha = 1.0
            videoLengthText?.alpha = 1.0
            break
        }
    }
    
    @objc func buttonTouchEvent() {
        mainClass?.toggleJSFullscreen()
    }
    
    func setupListeners() {
        seekBarSlider?.addTarget(self, action: #selector(onSliderStart(slider:event:)), for: .touchDown)
        seekBarSlider?.addTarget(self, action: #selector(onSliderValueChange(slider:event:)), for: .valueChanged)
        seekBarSlider?.addTarget(self, action: #selector(onSliderEnd(slider:event:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        setupDurationListener()
    }
    
    private func setupDurationListener() {
        let interval = CMTime(seconds:1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        timerToAttachObserver?.invalidate()
        
        if let player = avPlayer {
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
                if self.mainClass?.videoType == "normal" {
                    self.videoLength = Int(CMTimeGetSeconds((self.avPlayer?.currentItem?.asset.duration)!))
                    self.seekBarSlider?.maximumValue = Float(self.videoLength)
                    self.seekBarSlider?.isUserInteractionEnabled = true
                    self.videoLengthText?.text = self.secToHMS(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
                    
                    if !self.isSeeking {
                        let currentSecs = CMTimeGetSeconds(time)
                        
                        if self.currentTime != Int(currentSecs) {
                            self.mainClass?.hideBuffering()
                            self.currentTime = Int(currentSecs)
                            self.currentTimeText!.text = self.secToHMS(currentSecs)
                            self.seekBarSlider!.value = Float(currentSecs)
                        }
                    } else if self.resetSeeking {
                        self.isSeeking = false
                        //                    self.mainClass?.hideBuffering()
                    }
                } else {
                    self.mainClass?.hideBuffering()
                }
            }
        } else {
            timerToAttachObserver = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                self.setupDurationListener()
            }
        }
    }
    
    @objc func onSliderStart(slider: UISlider, event: UIEvent) {
        mainClass?.cancelTimer()
        isSeeking = true
    }
    
    @objc func onSliderValueChange(slider: UISlider, event: UIEvent) {
        if (!isSeeking) { return; }
        localCurrentTime = Int(slider.value)
        currentTimeText?.text = secToHMS(Double(localCurrentTime))
    }
    
    @objc func onSliderEnd(slider: UISlider, event: UIEvent) {        
        let seekTo = CMTimeMakeWithSeconds(Float64(localCurrentTime), preferredTimescale: 1)
        avPlayer?.seek(to: seekTo, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        self.mainClass?.restartTimer()
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            //            self.isSeeking = false
            self.resetSeeking = true
        }
    }
    
    func pad(_ numString:String) -> String {
        let temp:String = numString
        
        if (temp.count < 2) {
            return "0" + temp;
        }
        return temp;
    }
    
    func secToHMS (_ passedSecs:Double) -> String {
        let seconds = Int(passedSecs)
        let hourString = String(seconds / 3600)
        let minString = String((seconds % 3600) / 60)
        let secString = String((seconds % 3600) % 60)
        
        return pad(hourString) + ":" + pad(minString) + ":" + pad(secString)
    }
    
    func setTrackColor(_ val:String) {
        if (seekBarSlider != nil && !trackColorSet){
            setTrackColorTimer?.invalidate()
            seekBarSlider?.minimumTrackTintColor = CustomHelper.getUIColor(colorString: val)
            trackColorSet = true
        } else {
            setTrackColorTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
                self.setTrackColor(val)
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func changeZoomBtnImage(_ val:Bool) {
        if (zoomBtn == nil && stackView == nil) { return }
        if (val) {
            zoomBtn?.isHidden = true
            stackView?.removeArrangedSubview(zoomBtn!)
        } else if (showZoomButton) {
            zoomBtn?.isHidden = false
            stackView?.addArrangedSubview(zoomBtn!)
        }
    }
}

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
