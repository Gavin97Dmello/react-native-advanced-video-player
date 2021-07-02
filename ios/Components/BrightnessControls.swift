
import Foundation
import UIKit
import AVKit
import AVFoundation
import MediaPlayer

@available(iOS 10.0, *)
class BrightnessControls: UIStackView {
    //Value variables
    var parentHeight = 0
    var parentWidth = 0
    var startLocation: CGPoint = CGPoint.init(x: 0, y: 0)
    var isSwiping: Bool = false
    var currentBrightness: CGFloat = 0.0
    
    //UI variables
    var mainClass: RCTAdvancedVideoView?
    var brightnessIcon: UIImageView?
    var brightnessContainer: UIView?
    var brightnessIndicator: UIView?
    var brightnessBar: ProgressBarView?
    
    //Constraint variables
    var widthCons:NSLayoutConstraint?
    var heightCons:NSLayoutConstraint?
    var uiInit:Bool = false
    
    func setup(in container: UIView) {
        hideUI()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isLayoutMarginsRelativeArrangement = true
        self.axis = .vertical
        self.alignment = .center
        self.spacing = 5.0
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
            brightnessBar?.pgHeight = CGFloat(parentHeight) * 0.6 - 25
            brightnessBar?.setProgress(progressValue: currentBrightness)
            
            brightnessBar?.removeFromSuperview()
            brightnessIcon?.removeFromSuperview()
            setupChildUI()
        } else {
            widthCons = self.widthAnchor.constraint(equalToConstant: CGFloat(Double(parentWidth) * 0.15))
            widthCons?.isActive = true
            heightCons = self.heightAnchor.constraint(equalToConstant: CGFloat(Double(parentHeight) * 0.6))
            heightCons?.isActive = true
            self.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: -15).isActive = true
            self.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
        }
        
        if (uiInit) { return }
        uiInit = true
        setupChildUI()
        setupListeners()
        hideUI()
    }
    
    func setupChildUI() {
        brightnessIcon = UIImageView(image: UIImage(named: "brightness.png"))
        brightnessIcon?.contentMode = .scaleAspectFit
        brightnessIcon?.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        brightnessIcon?.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        self.addArrangedSubview(brightnessIcon!)
        
        brightnessBar = ProgressBarView()
        self.addArrangedSubview(brightnessBar!)
        brightnessBar?.pgWidth = 5
        brightnessBar?.frameBold = 2
        brightnessBar?.frameColor = .red
        brightnessBar?.pgHeight = CGFloat(parentHeight) * 0.6 - 25
        brightnessBar?.barColor = .white
        currentBrightness = UIScreen.main.brightness
        brightnessBar?.setProgress(progressValue: currentBrightness)
        
        if (!mainClass!.isVisible) {
            hideUI()}
    }
    
    func setupListeners() {
//        let swipeGesture = InstantPanGestureRecognizer(target: self, action: #selector(swipeGestureTriggered(gesture:)))
//        self.addGestureRecognizer(swipeGesture)
        
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self,
                               selector: #selector(brightnessDidChange),
                               name: UIScreen.brightnessDidChangeNotification,
                               object: nil)
    }
    
    func swipeBrightness(_ val:CGFloat) {
        showUI()
        
        let mContainerHeight = Float(parentHeight) * 0.6
        let ignoreTopHeight = Float(25.0)
        let bContainerHeight = mContainerHeight - ignoreTopHeight
        
        let changePercent = val/CGFloat(bContainerHeight)
        
        if (currentBrightness + changePercent >= 1.0){
            currentBrightness = 1.0
        } else if (currentBrightness + changePercent <= 0.0){
            currentBrightness = 0.0
        } else {
            currentBrightness += changePercent
        }
        
        UIScreen.main.brightness = currentBrightness
        brightnessBar?.setProgress(progressValue: currentBrightness)
    }
    
    @objc func brightnessDidChange() {
        if (isSwiping) { return }
        currentBrightness = UIScreen.main.brightness
        brightnessBar?.setProgress(progressValue: currentBrightness)
    }
    
    @objc func swipeGestureTriggered(gesture: InstantPanGestureRecognizer) {
        if (gesture.state == .began) {
            startLocation = gesture.location(in: self)
            
            isSwiping = true
            showUI()
            mainClass?.cancelTimer()
            setDeviceBrightness(getTouchedBrightness(startLocation.y))
        } else if (gesture.state == .ended) {
            isSwiping = false
            mainClass?.restartTimer()
        } else {
            let currLocation = gesture.location(in: self)
            
            setDeviceBrightness(getTouchedBrightness(currLocation.y))
        }
    }
    
    func setDeviceBrightness(_ value:Float){
        UIScreen.main.brightness = CGFloat(value)
        brightnessBar?.setProgress(progressValue: CGFloat(value))
    }
    
    func isLocationSettable(_ value:CGFloat) -> Bool {
        return true
        //        let mContainerHeight = Float(parentHeight) * 0.7
        //        let ignoreTopHeight = 25.0
        //
        //        if (value < CGFloat(ignoreTopHeight) || value > CGFloat(mContainerHeight)) { return false}
        //        return true
    }
    
    func getTouchedBrightness(_ value:CGFloat) -> Float {
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
