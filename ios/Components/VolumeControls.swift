
import Foundation
import UIKit
import AVKit
import AVFoundation
import MediaPlayer

@available(iOS 10.0, *)
class VolumeControls: UIStackView {
    //Value variables
    var parentHeight = 0
    var parentWidth = 0
    var startLocation: CGPoint = CGPoint.init(x: 0, y: 0)
    var isSwiping: Bool = false
    var currentVolume: CGFloat = 0.0
    var lastVolume: CGFloat = 0.0
    var devVolume: MPVolumeView?
    var isMuted: Bool = false
    
    //UI variables
    var mainClass: RCTAdvancedVideoView?
    var volumeIcon: UIImageView?
    var volumeBar: ProgressBarView?
    
    //Constraint variables
    var widthCons:NSLayoutConstraint?
    var heightCons:NSLayoutConstraint?
    var rightCons:NSLayoutConstraint?
    var uiInit:Bool = false
    
    func setup(in container: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isLayoutMarginsRelativeArrangement = true
        self.axis = .vertical
        self.alignment = .center
        self.spacing = 5.0
        
        hideUI()
        
        devVolume = MPVolumeView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        if let app = UIApplication.shared.delegate, let window = app.window {
            devVolume!.alpha = 0.000001
            window!.addSubview(devVolume!)
        }
    }
    
    func removeVolumeMask() {
        DispatchQueue.main.async {
            self.devVolume?.removeFromSuperview()
        }
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
        
        if (uiInit) {
            widthCons?.constant = CGFloat(Double(parentWidth) * 0.15)
            heightCons?.constant = CGFloat(Double(parentHeight) * 0.6)
            rightCons?.isActive = false
            rightCons = self.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: 15)
            rightCons?.isActive = true
            
            volumeBar?.pgHeight = CGFloat(parentHeight) * 0.6 - 25
            volumeBar?.setProgress(progressValue: currentVolume)
            
            volumeIcon?.removeFromSuperview()
            volumeBar?.removeFromSuperview()
            setupChildUI()
        } else {
            widthCons = self.widthAnchor.constraint(equalToConstant: CGFloat(Double(parentWidth) * 0.15))
            widthCons?.isActive = true
            heightCons = self.heightAnchor.constraint(equalToConstant: CGFloat(Double(parentHeight) * 0.6))
            heightCons?.isActive = true
            rightCons = self.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: 15)
            rightCons?.isActive = true
            self.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
        }
        
        if (uiInit) { return }
        uiInit = true
        setupChildUI()
        setupListeners()
        hideUI()
    }
    
    func setupChildUI() {
        volumeIcon = UIImageView(image: UIImage(named: "volume.png"))
        volumeIcon?.contentMode = .scaleAspectFit
        volumeIcon?.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        volumeIcon?.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        self.addArrangedSubview(volumeIcon!)
        
        volumeBar = ProgressBarView()
        self.addArrangedSubview(volumeBar!)
        volumeBar?.pgWidth = 5
        volumeBar?.frameBold = 2
        volumeBar?.frameColor = .red
        volumeBar?.pgHeight = CGFloat(parentHeight) * 0.6 - 25
        volumeBar?.barColor = .white
        currentVolume = CGFloat(MPVolumeView.getVolume())        
        volumeBar?.setProgress(progressValue: currentVolume)
        
        if (!mainClass!.isVisible) {
            hideUI()}
    }
    
    func setupListeners() {
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self,
                               selector: #selector(volumeDidChange),
                               name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
                               object: nil)
    }
    
    func swipeVolume(_ val:CGFloat) {
        showUI()
        
        isSwiping = true
        
        let mContainerHeight = Float(parentHeight) * 0.6
        let ignoreTopHeight = Float(25.0)
        let bContainerHeight = mContainerHeight - ignoreTopHeight
        
        let changePercent = val/CGFloat(bContainerHeight)
        
        if (currentVolume + changePercent >= 1.0){
            currentVolume = 1.0
        } else if (currentVolume + changePercent <= 0.0){
            currentVolume = 0.0
        } else {
            currentVolume += changePercent
        }
        
        if (!isMuted){
            MPVolumeView.setVolume(Float(currentVolume))
            volumeBar?.setProgress(progressValue: currentVolume)
        }
    }
    
    @objc func volumeDidChange(notification: NSNotification) {
        if (isSwiping) { return }
        showUI()
        let newVol = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as! Float
        currentVolume = CGFloat(newVol)
        
        if (!isMuted){
            volumeBar?.setProgress(progressValue: currentVolume)
        }
        mainClass?.restartTimer()
    }
    
    func mute() {
        DispatchQueue.main.async {
            self.isMuted = true
            MPVolumeView.setVolume(Float(0.0))
        }
    }
    
    func unmute() {
        DispatchQueue.main.async {
            self.isMuted = false
            
            if (self.currentVolume == CGFloat(0.0)){
                self.currentVolume = CGFloat(MPVolumeView.getVolume())
            }
            MPVolumeView.setVolume(Float(self.currentVolume))
            self.volumeBar?.setProgress(progressValue: self.currentVolume)
        }
    }
    
    func isLocationSettable(_ value:CGFloat) -> Bool {
        return true
    }
    
    func getTouchedVolume(_ value:CGFloat) -> Float {
        let mContainerHeight = Float(parentHeight) * 0.6
        let ignoreTopHeight = Float(25.0)
        let bContainerHeight = mContainerHeight - ignoreTopHeight
        
        let passedVal = Float(value) - ignoreTopHeight
        let touchedVal = Float(bContainerHeight) - passedVal
        
        var returnValue = touchedVal/bContainerHeight
        
        if (returnValue > 1.0){
            returnValue = 1.0
        } else if (returnValue < 0.0){
            returnValue = 0.0
        }
        
        return returnValue
    }
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView(frame: .zero)
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
    
    static func getVolume() -> Float {
        return AVAudioSession.sharedInstance().outputVolume
    }
}
