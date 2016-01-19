//
//  LEKManager.swift
//  LetEmKnow
//
//  Created by Keith Elliott on 1/11/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import Foundation

public class LEKManager: NSObject {
    var window: UIWindow!
    
    public init(mainWindow: UIWindow){
        self.window = mainWindow
        super.init()
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
        toastView.configure(title, message: message, backgroundColor: backgroundColor,titleColor: titleColor, textColor: textColor, icon: nil)
        
        animateToastIntoView(toastView)
    }
    
    public func sendToast(title: String? = nil, message: String, delayInSeconds: Double?, backgroundColor: UIColor, titleColor: UIColor, textColor: UIColor, icon: UIImage? = nil){
        let screen = UIScreen.mainScreen().bounds
        let frame = CGRect(x:(screen.width - 300)/2, y: screen.height - 60, width: 300, height: 60)
        let toastView = ToastView(frame: frame)
        toastView.configure(title, message: message, backgroundColor: backgroundColor,titleColor: titleColor, textColor: textColor, icon: nil)
        
        animateToastIntoView(toastView, delayInSeconds: delayInSeconds)
    }
    
    private func animateToastIntoView(toastView: UIView, delayInSeconds: Double? = nil){
        let screen = UIScreen.mainScreen().bounds
        if let topView = window.rootViewController?.view{
            var frame = toastView.frame
            frame.origin.y = frame.origin.y - toastView.frame.size.height - 20
            toastView.frame = frame
            
            UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, options: [.LayoutSubviews, .TransitionNone], animations: { () -> Void in
                var frame = toastView.frame
                frame.origin.y = screen.height - toastView.frame.size.height - 20
                toastView.frame = frame
                topView.addSubview(toastView)
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
            }
        })
    }
}