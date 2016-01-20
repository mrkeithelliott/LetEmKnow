//
//  LEKManager.swift
//  LetEmKnow
//
//  Created by Keith Elliott on 1/11/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import UIKit

public let LEK_NEW_TOAST_NOTIFICATION: String = "com.gittielabs.lek.new_toast_notification"
public let LEK_NEW_TOAST_SHOWN: String = "com.gittielabs.lek.new_toast_shown"
public let LEK_NEW_TOAST_DISMISSED: String = "com.gittielabs.lek.new_toast_dismissed"

public class LEKManager: NSObject {
    var window: UIWindow!
    var preferences: LEKPreferences!
    var networkMgr: LEKNetworkManager!
    var application: UIApplication!
    
    public static var sharedInstance = LEKManager()
    
    public class func setup(application: UIApplication){
        sharedInstance.window = application.windows[0]
        sharedInstance.application = application
        sharedInstance.preferences = LEKPreferences()
        sharedInstance.networkMgr = LEKNetworkManager(rootURL: "")
        
        
        sharedInstance.preferences.incrementAppLaunches()
    }
    
    private override init(){
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newToastReceived:", name: LEK_NEW_TOAST_NOTIFICATION, object: nil)
        
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(2) * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(LEK_NEW_TOAST_NOTIFICATION, object: nil, userInfo: ["toast" : ["title": "Test Toast Message", "message": "Test toast message with a really long explanation of really nothing at all.  Hopefully multilines", "icon": "https://test.com/icon", "backgroundColor": "#808080",
                "textColor": "white", "titleColor": "ffffff",
                "iconType": "Important"]])
        })
    }
    
    public func newToastReceived(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let toastDict = userInfo["toast"] as? NSDictionary,
            let toastObj: ToastMessage = ToastMessage.parse(toastDict){
                self.sendToast(toastObj.title, message: toastObj.message, delayInSeconds: 3, backgroundColor: toastObj.backgroundColor,titleColor: toastObj.titleColor, textColor: toastObj.textColor, icon: nil, iconType: toastObj.iconType)
        }
    }
    
    public func sendToast(title: String? = nil, message: String, icon: UIImage? = nil){
        let screen = UIScreen.mainScreen().bounds
        let frame = CGRect(x: (screen.width - 300)/2, y: screen.height - 60, width: 300, height: 60)
        let toastView = ToastView(frame: frame)
        toastView.configure(title, message: message, icon: icon)
        
        animateToastIntoView(toastView)
    }
    
    public func sendToast(title: String? = nil, message: String, backgroundColor: UIColor, titleColor: UIColor, textColor: UIColor, icon: UIImage? = nil){
        let screen = UIScreen.mainScreen().bounds
        let frame = CGRect(x:(screen.width - 300)/2, y: screen.height - 60, width: 300, height: 60)
        let toastView = ToastView(frame: frame)
        toastView.configure(title, message: message, backgroundColor: backgroundColor,titleColor: titleColor, textColor: textColor, icon: icon, iconType: nil)
        
        animateToastIntoView(toastView)
    }
    
    public func sendToast(title: String? = nil, message: String, delayInSeconds: Double?, backgroundColor: UIColor, titleColor: UIColor, textColor: UIColor, icon: UIImage? = nil, iconType: IconType? = nil){
        let screen = UIScreen.mainScreen().bounds
        let frame = CGRect(x:(screen.width - 300)/2, y: screen.height - 60, width: 300, height: 60)
        let toastView = ToastView(frame: frame)
        toastView.configure(title, message: message, backgroundColor: backgroundColor,titleColor: titleColor, textColor: textColor, icon: icon, iconType: iconType)
        
        animateToastIntoView(toastView, delayInSeconds: delayInSeconds)
    }
    
    private func animateToastIntoView(toastView: UIView, delayInSeconds: Double? = nil){
        let screen = UIScreen.mainScreen().bounds
        if let topView = window.rootViewController?.view{
            var frame = toastView.frame
            frame.origin.y = frame.origin.y + toastView.frame.size.height + 20
            toastView.frame = frame
            
            UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, options: [.LayoutSubviews, .TransitionNone], animations: { () -> Void in
                var frame = toastView.frame
                frame.origin.y = screen.height - toastView.frame.size.height - 20
                toastView.frame = frame
                topView.addSubview(toastView)
                NSNotificationCenter.defaultCenter().postNotificationName(LEK_NEW_TOAST_SHOWN, object: nil)
                
                }){ (status) in
                    if delayInSeconds != nil {
                        self.dismissToastView(toastView, delayInSeconds: delayInSeconds)
                    }
            }
            
        }
    }
    
    private func dismissToastView(toastView: UIView, delayInSeconds: Double?){
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(delayInSeconds!) * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1.0, options: [.LayoutSubviews, .TransitionNone], animations: { () -> Void in
                var frame = toastView.frame
                frame.origin.y = frame.origin.y + toastView.frame.size.height + 30
                toastView.frame = frame
                }) { (complete) -> Void in
                    toastView.removeFromSuperview()
                    NSNotificationCenter.defaultCenter().postNotificationName(LEK_NEW_TOAST_DISMISSED, object: nil)
            }
        })
    }
}