//
//  HomeIndicator.swift
//  appcenter-analytics
//
//  Created by Sim Hann Zern  on 03/09/2020.
//
import UIKit
import Foundation
class HomeIndicator: UIViewController
{
    var hideHomeIndicator = false

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print("HOME INDICATOR VIEWDIDLOAD")
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return self.hideHomeIndicator
    }
}
