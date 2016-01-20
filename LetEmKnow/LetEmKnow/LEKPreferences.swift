//
//  LEKPreferences.swift
//  LetEmKnow
//
//  Created by Keith Elliott on 1/19/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import Foundation

let LEK_APP_LAUNCHES = "com.gittielabs.applaunches"
let LEK_APP_LAUNCHES_CHANGED = "com.gittielabs.applaunches.changed"
let LEK_APP_ID = "com.gittielabs.appId"
let LEK_LAST_APPSTORE_CHECK = "com.gittielabs.last_appstore_check"
let LEK_INSTALL_DATE = "com.gittielabs.install_date"

public struct LEKPreferences {
    let userdefaults = NSUserDefaults()
    var appId: String!
    var triggers: [Int: ()->Void]
    
    init(){
        self.triggers = [:]
    }
    
    func incrementAppLaunches(){
        var launches = userdefaults.integerForKey(LEK_APP_LAUNCHES)
        launches++
        userdefaults.setInteger(launches, forKey: LEK_APP_LAUNCHES)
        userdefaults.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(LEK_APP_LAUNCHES_CHANGED, object: nil, userInfo: ["app_launches": launches])
    }
    
    func getAppLaunchCount() -> Int {
        let launches = userdefaults.integerForKey(LEK_APP_LAUNCHES)
        return launches
    }
    
    func setAppId(appId: String){
        userdefaults.setObject(appId, forKey: LEK_APP_ID)
        userdefaults.synchronize()
    }
    
    mutating func getAppId()->String?{
        if appId == nil {
            appId = userdefaults.stringForKey(LEK_APP_ID)
        }
        
        return appId
    }

    func setLastAppStoreCheck(date: NSDate){
        userdefaults.setObject(date, forKey: LEK_LAST_APPSTORE_CHECK)
        userdefaults.synchronize()
    }
    
    func getLastAppStoreCheck()->NSDate? {
        let date = userdefaults.objectForKey(LEK_LAST_APPSTORE_CHECK) as? NSDate
        return date
    }
    
    func setInstalledDate() {
        let date = NSDate()
        userdefaults.setObject(date, forKey: LEK_INSTALL_DATE)
        userdefaults.synchronize()
    }
    
    func getInstalledDate() ->NSDate?{
        let date = userdefaults.objectForKey(LEK_INSTALL_DATE) as? NSDate
        return date
    }
    
}