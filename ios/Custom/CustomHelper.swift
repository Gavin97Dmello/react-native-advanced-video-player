//
//  CustomHelper.swift
//  AdvancedVideoPlayer
//
//  Created by Sim Hann Zern  on 30/06/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

class CustomHelper {
    static func getUIColor(colorString: String) -> UIColor {
        var redVal:CGFloat = 0.0
        var greenVal:CGFloat = 0.0
        var blueVal:CGFloat = 0.0
        var alphaVal:CGFloat = 1.0
        
        var tempString:String
        
        var finalColor:UIColor = UIColor.white
        
        if (colorString.contains("rgb")) {
            tempString = colorString.replacingOccurrences(of: "rgb(", with: "")
            tempString = tempString.replacingOccurrences(of: " ", with: "")
            tempString = tempString.replacingOccurrences(of: ")", with: "")
            
            let stringArr = tempString.split(separator: ",")
            
            if (stringArr.count >= 3){
                redVal = CGFloat(truncating: NumberFormatter().number(from: String(stringArr[0]))!) / 255.0
                greenVal = CGFloat(truncating: NumberFormatter().number(from: String(stringArr[1]))!) / 255.0
                blueVal = CGFloat(truncating: NumberFormatter().number(from: String(stringArr[2]))!) / 255.0
            }
            
            if (stringArr.count == 4) {
                alphaVal = CGFloat(truncating: NumberFormatter().number(from: String(stringArr[3]))!)
            }
            
            finalColor = UIColor(red: redVal, green: greenVal, blue: blueVal, alpha: alphaVal)
        } else if (colorString.contains("#")) {
            finalColor = UIColor(hex: colorString)
        }
        
        return finalColor
    }
    
    static func getStreamType(_ url:String) -> String {
        if url.contains("rtmp") {
            return "rtmp"
        } else if url.contains("m3u8") {
            return "m3u8"
        } else {
            return "normal"
        }
    }
}

extension UIColor {
    public convenience init(hex: String) {
        var r: CGFloat = 255
        var g: CGFloat = 255
        var b: CGFloat = 255
        var a: CGFloat = 1

        let hexColor = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        var valid = false

        if scanner.scanHexInt64(&hexNumber) {
            if hexColor.count == 8 {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000ff) / 255
                valid = true
            }
            else if hexColor.count == 6 {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000ff) / 255
                valid = true
            }
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
