import Foundation
import UIKit
import AVKit
import AVFoundation

@available(iOS 10.0, *)
class PlayPauseButton: UIView {
    var kvoRateContext = 0
    //    var vlcPlayer: VLCMediaPlayer?
    var avPlayer: CustomAVPlayer?
    var isPlaying: Bool = false
    var loadingSpinner: UIActivityIndicatorView?
    var mainClass: RCTAdvancedVideoView?
    
    func hideUI() {
        self.alpha = 0.0
    }
    
    func showUI(_ status:String) {
        DispatchQueue.main.async {
            if status == "play" {
                self.setBackgroundImage(name: "play.png")
            } else {
                self.setBackgroundImage(name: "pause.png")
            }
            self.alpha = 1.0
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                self.hideUI()
            }
        }
    }
    
    func setup(in container: UIView) {
        self.backgroundColor = .none
        
        updatePosition()
        hideUI()
        
        self.setBackgroundImage(name: "pause.png")
    }
    
    func updatePosition() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 50),
            heightAnchor.constraint(equalToConstant: 50),
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }
    
    func setBackgroundImage(name: String) {
        UIGraphicsBeginImageContext(frame.size)
        UIImage(named: name)?.draw(in: bounds)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        backgroundColor = UIColor(patternImage: image)
    }
}
