//
//  VerticalProgressBar.swift
//  VHProgressBar
//
//  Created by Sohei Miyakura on 2018/11/21.
//

import UIKit

@available(iOS 10.0, *)
@IBDesignable
open class ProgressBarView: UIView {
    
    fileprivate var progressView: UIView!
    fileprivate var animator: UIViewPropertyAnimator!
    fileprivate var isAnimating: Bool = false
    
    @IBInspectable public var bgColor: UIColor = UIColor.white {
        didSet {
            configureView()
        }
    }
    
    @IBInspectable public var barColor: UIColor = UIColor.init(red: 52/255, green: 181/255, blue: 240/255, alpha: 1) {
        didSet {
            configureView()
        }
    }
    
    @IBInspectable public var frameColor: UIColor = .red {
        didSet {
            configureView()
        }
    }
    
//    @IBInspectable public var frameColor: UIColor = UIColor.init(red: 161/255, green: 161/255, blue: 161/255, alpha: 1) {
//        didSet {
//            configureView()
//        }
//    }
    
    @IBInspectable public var frameBold: CGFloat = 1.0 {
        didSet {
            configureView()
        }
    }
    
    @IBInspectable public var pgHeight: CGFloat = 200 {
        didSet {
            configureView()
        }
    }
    
    @IBInspectable public var pgWidth: CGFloat = 20 {
        didSet {
            configureView()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initProgressView()
        self.backgroundColor = .purple
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        initProgressView()
        self.backgroundColor = .purple
    }
}

@available(iOS 10.0, *)
extension ProgressBarView {
    
    fileprivate func initProgressView() {
        progressView = UIView()
        addSubview(progressView)
    }
    
    fileprivate func configureProgressView() {
        progressView.backgroundColor = barColor
        progressView.frame.size.height = 0
        progressView.frame.size.width = pgWidth
        progressView.frame.origin.y = self.bounds.origin.y + pgHeight
        progressView.layer.cornerRadius = pgWidth / 2
    }
    
    fileprivate func configureView() {
        setBackgroundColor()
        setFrameColor()
        setFrameBold()
        setProgressBarHeight()
        setProgressBarWidth()
        setProgressBarRadius()
    }
    
    fileprivate func setBackgroundColor() {
        self.backgroundColor = bgColor
    }
    
    fileprivate func setFrameColor() {
        self.layer.borderColor = frameColor.cgColor
    }
    
    fileprivate func setFrameBold() {
        self.layer.borderWidth = frameBold
    }
    
    fileprivate func setProgressBarHeight() {
        self.frame.size.height = pgHeight
    }
    
    fileprivate func setProgressBarWidth() {
        self.frame.size.width = pgWidth
    }
    
    fileprivate func setProgressBarRadius() {
        self.layer.cornerRadius = pgWidth / 2
    }
}

@available(iOS 10.0, *)
extension ProgressBarView {
    
    open func setProgress(progressValue: CGFloat) {
        if !(0 < progressValue || progressValue < 1.0) {
            return
        }
        configureProgressView()
        self.progressView.frame.size.height -= self.pgHeight * progressValue
    }
    
    open func getProgress() -> CGFloat {
        return self.progressView.frame.size.height
    }
}
