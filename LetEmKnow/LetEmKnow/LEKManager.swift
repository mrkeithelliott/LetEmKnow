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
public let LEK_APP_STORE_UPDATE_RETREIVED = "com.gittielabs.lek.appstore_update_retreived"

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
        
        let app_name = NSBundle(forClass: application.delegate!.dynamicType).infoDictionary!["CFBundleName"] as? String
        sharedInstance.preferences.setAppName(app_name!)
        sharedInstance.preferences.setAppId("661035659")
        sharedInstance.preferences.setLaunchesBeforeRating(1)
        sharedInstance.preferences.setLaunchesBeforeCheckingAppVersion(5)
        sharedInstance.preferences.incrementAppLaunches()
    }
    
    private override init(){
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newToastReceived:", name: LEK_NEW_TOAST_NOTIFICATION, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rateTheApp:", name: LEK_APP_LAUNCHES_CHANGED, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidBecomeActive:", name:UIApplicationDidBecomeActiveNotification , object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidFinishLaunching:" , name: UIApplicationDidFinishLaunchingNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillTerminate:", name: UIApplicationWillTerminateNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appStoreUpdated:", name: LEK_APP_STORE_UPDATE_RETREIVED, object: nil)

    }
    
    public func newToastReceived(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let toastDict = userInfo["toast"] as? NSDictionary,
            let toastObj: ToastMessage = ToastMessage.parse(toastDict){
                self.sendToast(toastObj.title, message: toastObj.message, delayInSeconds: 3, backgroundColor: toastObj.backgroundColor,titleColor: toastObj.titleColor, textColor: toastObj.textColor, icon: nil, iconType: toastObj.iconType)
        }
    }
    
    public func appDidBecomeActive(notification: NSNotification){
       networkMgr.checkForNewMessages()
        
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(2) * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(LEK_NEW_TOAST_NOTIFICATION, object: nil, userInfo: ["toast" : ["title": "Test Toast Message", "message": "Test toast message with a really long explanation of really nothing at all.  Hopefully multilines", "icon": "https://test.com/icon", "backgroundColor": "#808080",
                "textColor": "white", "titleColor": "ffffff",
                "iconType": "Important"]])
        })
    }
    
    public func appDidFinishLaunching(notification: NSNotification){
        let calendar = NSCalendar.currentCalendar()
        let today = NSDate()
        
        if let appId = self.preferences.getAppId(){
            let launches = self.preferences.getAppLaunchCount()
            let launchesBeforeAppVersionCheck = self.preferences.getLaunchesBeforeCheckingAppVersion()
            let lastAppVersionCheck = self.preferences.getLastAppStoreCheck() ?? today
            if launches > launchesBeforeAppVersionCheck && calendar.compareDate(lastAppVersionCheck, toDate: today, toUnitGranularity: .Day) == .OrderedAscending{
                networkMgr.checkForAppStoreUpdates(appId)
            }
        }
    }
    
    public func appWillEnterForeground(notification: NSNotification){
    }
    
    public func appWillTerminate(notification: NSNotification){
        networkMgr.saveUpdates()
    }
    
    public func appDidEnterBackground(notification: NSNotification){
        networkMgr.saveUpdates()
    }
    
    public func rateTheApp(notification: NSNotification){
        let calendar = NSCalendar.currentCalendar()
        let userinfo = notification.userInfo
        let today = NSDate()
        let requiredLaunches = LEKManager.sharedInstance.preferences.getLaunchesRequiredBeforeRating()
        let lastRatingsCheck = self.preferences.getLastRatingsCheckDate() ?? today
        if let app_launches = userinfo?["app_launches"] as? Int{
            if app_launches > requiredLaunches && calendar.compareDate(lastRatingsCheck, toDate: today, toUnitGranularity: .Day) == .OrderedAscending{
                let app_name = self.preferences.getAppName()
                let message = "Do you love the \(app_name!) app?  Please rate us!"
                let rateAlert = UIAlertController(title: "Rate Us", message: message, preferredStyle: .Alert)
                let goToItunesAction = UIAlertAction(title: "Update Now", style: .Default, handler: { (action) -> Void in
                    let appId = LEKManager.sharedInstance.preferences.getAppId()
                    let url = NSURL(string: "itms-apps://itunes.apple.com/app/id\(appId)")
                    UIApplication.sharedApplication().openURL(url!)
                })
                
                let cancelAction = UIAlertAction(title: "Not Now", style: .Cancel, handler: { (action) -> Void in
                    
                })
                
                rateAlert.addAction(cancelAction)
                rateAlert.addAction(goToItunesAction)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    LEKManager.sharedInstance.window.rootViewController?.presentViewController(rateAlert, animated: true, completion: nil)
                })
                
                self.preferences.setLastRatingsCheck()
            }
        }
    }
    
    public func appStoreUpdated(notification: NSNotification) {
        if let userinfo = notification.userInfo{
            let version = userinfo["version"] as? String
            let installedVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String

            if version != installedVersion{
                // Display view to update app
                let message = "Version \(version!) is now available."
                let updateAlert = UIAlertController(title: "Update Available", message: message, preferredStyle: .Alert)
                let goToItunesAction = UIAlertAction(title: "Update Now", style: .Default, handler: { (action) -> Void in
                    let appId = userinfo["appId"] as? NSNumber
                    let url = NSURL(string: "itms-apps://itunes.apple.com/app/id\(appId!.stringValue)")
                    UIApplication.sharedApplication().openURL(url!)
                })
            
                let cancelAction = UIAlertAction(title: "Not Now", style: .Cancel, handler: { (action) -> Void in
                    
                })
                
                updateAlert.addAction(cancelAction)
                updateAlert.addAction(goToItunesAction)
                LEKManager.sharedInstance.window.rootViewController?.presentViewController(updateAlert, animated: true, completion: nil)
                
                self.preferences.setLastAppStoreCheck()
            }
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