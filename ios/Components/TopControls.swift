import Foundation
import UIKit
import AVKit
import AVFoundation

@available(iOS 10.0, *)
class TopControls: UIView {
    var kvoRateContext = 0
    var parentWidth = 0
    var uiInit:Bool = false
    
    //Value variables
    var currentTime:Int = 0
    var videoLength:Int = 0
    var localCurrentTime:Int = 0
    var isSeeking:Bool = false
    var resetSeeking:Bool = false
    
    //UI variables
    var mainClass: RCTAdvancedVideoView?
    var gradientBg: CAGradientLayer?
    var stackView: UIStackView?
    var dummyText: UILabel?
    var currentTimeText: UILabel?
    var seekBarSlider: UISlider?
    var videoLengthText: UILabel?
    var zoomBtn: UIButton?
    
    var titleText: UILabel?
    var backBtn: UIButton?
    var likeBtn: UIButton?
    var shareBtn: UIButton?
    var downloadBtn: UIButton?
    var refreshBtn: UIButton?
    
    //Prop variables
    var showLikeBtn: Bool = true
    var showShareBtn: Bool = true
    var showDownloadBtn: Bool = true
    var showBackBtn: Bool = true
    
    //Styling variables
    var titleTextSet:Bool = false
    var setTitleTextTimer:Timer?
    
    var isLikeSet:Bool = false
    var setIsLikeTimer:Timer?
    
    //Constraint variables
    var widthCons: NSLayoutConstraint?
    var heightCons: NSLayoutConstraint?
    var svWidthCons: NSLayoutConstraint?
    
    func setup(in container: UIView) {
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
        
        if (uiInit) {
            widthCons?.constant = CGFloat(parentWidth)
            svWidthCons?.constant = CGFloat(parentWidth)
        } else {
            widthCons = self.widthAnchor.constraint(equalToConstant: CGFloat(parentWidth))
            widthCons?.isActive = true
            heightCons = self.heightAnchor.constraint(equalToConstant: 30)
            heightCons?.isActive = true
            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
            self.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        }
        
        if (!uiInit) {
            uiInit = true
            hideUI()
            setupChildUI()
            
            gradientBg = CAGradientLayer()
            gradientBg!.frame = CGRect(x: 0, y: 0, width: parentWidth, height: 35)
            gradientBg!.colors = [UIColor(red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(0.75)).cgColor, UIColor(red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(0.05)).cgColor]
            
            self.layer.insertSublayer(gradientBg!, at: 0)
        } else {
            gradientBg?.frame.size.width = CGFloat(parentWidth)
        }
    }
    
    func setupChildUI() {
        stackView = UIStackView()
        stackView?.translatesAutoresizingMaskIntoConstraints = false
        stackView?.isLayoutMarginsRelativeArrangement = true
        stackView?.axis = .horizontal
        stackView?.spacing = 10
        
        self.addSubview(stackView!)
        
        svWidthCons = stackView!.widthAnchor.constraint(equalToConstant: CGFloat(parentWidth))
        svWidthCons?.isActive = true
        
        stackView?.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 7.5)
        stackView?.addBackground(color: .clear)
        
        backBtn = UIButton()
        backBtn?.setImage(UIImage(named: "back.png"), for: .normal)
        backBtn?.addTarget(self, action: #selector(buttonTouched(sender:)), for: .touchUpInside)
        backBtn?.tag = 0
        //        stackView?.addArrangedSubview(backBtn!)
        backBtn?.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
        backBtn?.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        
        titleText = UILabel()
        titleText?.text = ""
        titleText?.textColor = .white
        stackView?.addArrangedSubview(titleText!)
        
        likeBtn = UIButton()
        likeBtn?.setImage(UIImage(named: "bookmark.png"), for: .normal)
        likeBtn?.addTarget(self, action: #selector(buttonTouched(sender:)), for: .touchUpInside)
        likeBtn?.tag = 1
        
        if (showLikeBtn){
            stackView?.addArrangedSubview(likeBtn!)
            likeBtn?.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
            likeBtn?.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        }
        
        shareBtn = UIButton()
        shareBtn?.setImage(UIImage(named: "share.png"), for: .normal)
        shareBtn?.addTarget(self, action: #selector(buttonTouched(sender:)), for: .touchUpInside)
        shareBtn?.tag = 2
        
        if (showShareBtn){
            stackView?.addArrangedSubview(shareBtn!)
            shareBtn?.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
            shareBtn?.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        }
        
        downloadBtn = UIButton()
        downloadBtn?.setImage(UIImage(named: "download.png"), for: .normal)
        downloadBtn?.addTarget(self, action: #selector(buttonTouched(sender:)), for: .touchUpInside)
        downloadBtn?.tag = 3
        
        if (showDownloadBtn){
            stackView?.addArrangedSubview(downloadBtn!)
            downloadBtn?.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
            downloadBtn?.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        }
        
        refreshBtn = UIButton()
        refreshBtn?.setImage(UIImage(named: "refresh.png"), for: .normal)
        refreshBtn?.addTarget(self, action: #selector(buttonTouched(sender:)), for: .touchUpInside)
        refreshBtn?.tag = 4
        
        stackView?.addArrangedSubview(refreshBtn!)
        refreshBtn?.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
        refreshBtn?.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        
    }
    
    @objc func buttonTouched(sender: UIButton!) {
        mainClass?.cancelTimer()
        
        let btnTag = sender!.tag
        
        mainClass?.btnPressed(btnTag: btnTag)
    }
    
    func setTitleText(_ val:String) {
        if (titleText != nil && !titleTextSet){
            setTitleTextTimer?.invalidate()
            titleText!.text = val
        } else {
            setTitleTextTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                self.setTitleText(val)
            }
        }
    }
    
    func setIsLike(_ val:Bool) {
        if (likeBtn != nil && !isLikeSet){
            setIsLikeTimer?.invalidate()
            
            if (val) {
                likeBtn?.setImage(UIImage(named: "favourite.png"), for: .normal)
            } else {
                likeBtn?.setImage(UIImage(named: "bookmark.png"), for: .normal)
            }
        } else {
            setIsLikeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                self.setIsLike(val)
            }
        }
    }
    
    func changeBackBtnStatus(_ val:Bool) {
        if (backBtn == nil || stackView == nil)  { return }
        if (val && showBackBtn) {
            backBtn?.isHidden = false
            stackView?.insertArrangedSubview(backBtn!, at: 0)
        } else {
            backBtn?.isHidden = true
            stackView?.removeArrangedSubview(backBtn!)
        }
    }
    
    func showHideRefreshButton(_ val:Bool) {
        refreshBtn?.removeFromSuperview()
        
        if (val){
            stackView?.addArrangedSubview(refreshBtn!)
        }
    }
}
