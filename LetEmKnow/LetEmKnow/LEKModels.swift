//
//  LEKModels.swift
//  LetEmKnow
//
//  Created by Keith Elliott on 1/20/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import Foundation

public enum IconType: String {
    case Important = "Important"
    case Information = "Information"
}

public struct ToastMessage{
    public var title: String
    public var message: String
    public var icon: NSURL!
    public var iconType: IconType!
    public var backgroundColor: UIColor
    public var titleColor: UIColor
    public var textColor: UIColor
    
    public static func parse(dict: NSDictionary)->ToastMessage?{
        switch (dict.valueForKeyPath("title") as? String,
            dict.valueForKeyPath("message") as? String,
            dict.valueForKeyPath("icon") as? String,
            dict.valueForKeyPath("backgroundColor") as? String,
            dict.valueForKeyPath("titleColor") as? String,
            dict.valueForKeyPath("textColor") as? String,
            dict.valueForKeyPath("iconType") as? String) {
        case (let title, let message, let icon, let backgroundColor, let titleColor, let textColor, let iconType) where title != nil && message != nil:
            
            let iconURL = NSURL(string: icon!)
            let _titleColor = UIColor.getColor(titleColor!) ?? UIColor.whiteColor()
            let _backgroundColor = UIColor.getColor(backgroundColor!) ?? UIColor.redColor()
            let _textColor = UIColor.getColor(textColor!) ?? UIColor.whiteColor()
            let _iconType = IconType(rawValue: iconType!)
            
            let toast = ToastMessage(title: title!, message: message!, icon: iconURL!, iconType: _iconType, backgroundColor: _backgroundColor, titleColor: _titleColor, textColor: _textColor)
            
            return toast
        default:
            return nil
            
        }
    }
}

public struct ImageDisplayMessage{
    public var imageURL: NSURL!
    
    public static func parse(dict: NSDictionary)->ImageDisplayMessage?{
        switch (dict.valueForKeyPath("image_url") as? String){
        case (let image_url):
            let imageURL = NSURL(string: image_url!)
            
            let imgDisplayMessage = ImageDisplayMessage(imageURL: imageURL)
            return imgDisplayMessage
        }
    }
}

public struct LEKAppInfo{
    public var version: String
    public var appId: NSNumber
    
    public static func parse(json: NSDictionary)->LEKAppInfo?{
        switch (json.valueForKeyPath("version") as! String,
                json.valueForKeyPath("trackId") as! NSNumber) {
            case (let version, let appId):
                let appInfo = LEKAppInfo(version: version, appId: appId)
                return appInfo
        }
    }
}

public extension UIColor{
    public  class func colorFromHex(hexString: String) -> UIColor {
        var hexStr = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if hexStr.hasPrefix("#") {
            hexStr = hexStr.substringFromIndex(hexStr.startIndex.advancedBy(1))
        }
        
        hexStr = hexStr.uppercaseString
        
        if let hex = UInt(hexStr, radix: 16){
            
            let red = CGFloat((hex & 0xFF0000) >> 16) / 256.0
            let green = CGFloat((hex & 0xFF00) >> 8) / 256.0
            let blue = CGFloat(hex & 0xFF) / 256.0
            
            return UIColor(red: red, green: green, blue: blue, alpha: 1)
        }
        
        return UIColor.blackColor()
    }
    
    public class func getColor(colorString: String) -> UIColor?{
        switch (colorString.lowercaseString){
        case (let color) where color == "red":
            return UIColor.redColor()
        case (let color) where color == "white":
            return UIColor.whiteColor()
        case (let color) where color == "black":
            return UIColor.blackColor()
        case (let color) where color == "blue":
            return UIColor.blueColor()
        default:
            return UIColor.colorFromHex(colorString)
        }
    }
}
