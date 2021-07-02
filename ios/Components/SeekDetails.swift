import Foundation
import UIKit
import AVKit
import AVFoundation

@available(iOS 10.0, *)
class SeekDetails: UIView {
    var parentHeight = 0
    var parentWidth = 0
    //    var vlcPlayer: CustomVLCPlayer?
    var avPlayer: CustomAVPlayer?
    var isPlaying: Bool {
        return avPlayer?.rate != 0 && avPlayer?.error == nil
    }
    
    //Value variables
    var started:Bool = false
    var initCurrTime:Int = 0
    var seekAmount:Int = 0
    var videoLength:Int = 0
    
    //Constraint variables
    var widthCons:NSLayoutConstraint?
    var heightCons:NSLayoutConstraint?
    var uiInit:Bool = false
    
    //UI variables
    var mainClass: RCTAdvancedVideoView?
    var currentTimeText: UILabel?
    var bigContainer: UIStackView?
    var btmContainer: UIStackView?
    var seekAmountText: UILabel?
    var videoLengthText: UILabel?
    
    func setup(in container: UIView) {
        
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        updateStatus()
    }
    
    private func updateStatus() {
        if isPlaying {
            avPlayer?.pause()
        } else {
            avPlayer?.play()
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
            widthCons?.constant = CGFloat(Double(parentWidth) * 0.5)
            heightCons?.constant = CGFloat(Double(parentHeight) * 0.4)
        } else {
            widthCons = self.widthAnchor.constraint(equalToConstant: CGFloat(Double(parentWidth) * 0.5))
            widthCons?.isActive = true
            heightCons = self.heightAnchor.constraint(equalToConstant: CGFloat(Double(parentHeight) * 0.4))
            heightCons?.isActive = true
            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
            self.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
        }
        
        if (uiInit) { return }
        uiInit = true
        hideUI()
        setupChildUI()
    }
    
    func setupChildUI() {
        guard let superview = superview else { return }
        
        bigContainer = UIStackView()
        bigContainer?.translatesAutoresizingMaskIntoConstraints = false
        bigContainer?.isLayoutMarginsRelativeArrangement = true
        bigContainer?.axis = .vertical
        bigContainer?.spacing = 5.0
        bigContainer?.alignment = .center
        
        seekAmountText = UILabel()
        seekAmountText?.text = "30 seconds"
        seekAmountText?.sizeToFit()
        seekAmountText?.textColor = .white
        bigContainer?.addArrangedSubview(seekAmountText!)
        
        btmContainer = UIStackView()
        btmContainer?.translatesAutoresizingMaskIntoConstraints = false
        btmContainer?.isLayoutMarginsRelativeArrangement = true
        btmContainer?.axis = .horizontal
        btmContainer?.spacing = 0.0
        
        currentTimeText = UILabel()
        currentTimeText?.text = "00:00:00"
        currentTimeText?.textColor = .white
        currentTimeText?.sizeToFit()
        btmContainer?.addArrangedSubview(currentTimeText!)
        
        videoLengthText = UILabel()
        videoLengthText?.text = " / 23:59:59"
        videoLengthText?.sizeToFit()
        videoLengthText?.textColor = .white
        btmContainer?.addArrangedSubview(videoLengthText!)
        
        bigContainer?.addArrangedSubview(btmContainer!)
        
        self.addSubview(bigContainer!)
        self.backgroundColor = UIColor(red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(0.75))
        
        bigContainer?.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        bigContainer?.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
    }
    
    func start() {
        started = true
        
        if let player = avPlayer {
            initCurrTime = Int(CMTimeGetSeconds((player.currentItem?.currentTime())!))
            videoLength = Int(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
            seekAmount = 0
            addSeekAmount(0)
            
            currentTimeText?.text = secToHMS(Double(initCurrTime))
            videoLengthText?.text = " / " + secToHMS(Double(videoLength))
            showUI()
        }
    }
    
    func addSeekAmount(_ amount:Int) {
        if ((initCurrTime + amount) >= videoLength){
            seekAmount += (videoLength - initCurrTime)
            initCurrTime = videoLength
        } else {
            seekAmount += amount
            initCurrTime += amount
        }
        
        if (seekAmount >= 0) {
            seekAmountText?.text = "+ \(String(seekAmount)) seconds"
        } else if (seekAmount < 0) {
            seekAmountText?.text = "- \(String(seekAmount)) seconds"
        }
        currentTimeText?.text = secToHMS(Double(initCurrTime))
    }
    
    func minusSeekAmount(_ amount:Int) {
        if ((initCurrTime - amount) <= 0){
            seekAmount -= initCurrTime
            initCurrTime = 0
        } else {
            seekAmount -= amount
            initCurrTime -= amount
        }
        
        if (seekAmount >= 0) {
            seekAmountText?.text = "+ \(String(seekAmount)) seconds"
        } else {
            seekAmountText?.text = "- \(String(abs(seekAmount))) seconds"
        }
        currentTimeText?.text = secToHMS(Double(initCurrTime))
    }
    
    func done() {
        if (self.alpha < 1) { return }
        
        if let player = avPlayer {
            player.seek(to: CMTimeMakeWithSeconds(Float64(initCurrTime), preferredTimescale: 1), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            mainClass?.bottomControls?.currentTime = initCurrTime
            mainClass?.bottomControls?.currentTimeText?.text = mainClass?.bottomControls?.secToHMS(Double(initCurrTime))
            mainClass?.bottomControls?.seekBarSlider?.value = Float(initCurrTime)
            
            initCurrTime = 0
            seekAmount = 0
            videoLength = 0
            hideUI()
            started = false
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
}
