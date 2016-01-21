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
let LEK_LAST_RATINGS_CHECK_DATE = "com.gittielabs.last_ratings_check_date"
let LEK_REQUIRED_LAUNCHES_BEFORE_RATING = "com.gittielabs.required_launches_before_rating"
let LEK_REQUIRED_LAUNCHES_BEFORE_APPVERSION = "com.gittielabs.required_launches_before_appversion"
let LEK_APP_NAME = "com.gittielabs.appname"

public struct LEKPreferences {
    let userdefaults = NSUserDefaults()
    var appId: String!
    var triggers: [Int: ()->Void]
    var config: LEKConfig!
    
    //MARK: - Setup
    init(){
        self.triggers = [:]
        self.config = LEKConfig()
    }
    
    //MARK: - App Name
    mutating func setAppName(name: String){
        userdefaults.setObject(name, forKey: LEK_APP_NAME)
        userdefaults.synchronize()
        self.config.appName = name
    }
    
    func getAppName()->String?{
        let name = userdefaults.objectForKey(LEK_APP_NAME) as? String
        return name
    }
    
    //MARK: - App Launches
    mutating func incrementAppLaunches(){
        var launches = userdefaults.integerForKey(LEK_APP_LAUNCHES)
        launches++
        userdefaults.setInteger(launches, forKey: LEK_APP_LAUNCHES)
        userdefaults.synchronize()
        self.config.appLaunchCount = launches
    
        NSNotificationCenter.defaultCenter().postNotificationName(LEK_APP_LAUNCHES_CHANGED, object: nil, userInfo: ["app_launches": launches])
    }
    
    func getAppLaunchCount() -> Int {
        let launches = userdefaults.integerForKey(LEK_APP_LAUNCHES)
        return launches
    }
    
    //MARK: - App Id
    mutating func setAppId(appId: String){
        userdefaults.setObject(appId, forKey: LEK_APP_ID)
        userdefaults.synchronize()
        
        self.config.appId = appId
    }
    
    mutating func getAppId()->String?{
        if appId == nil {
            appId = userdefaults.stringForKey(LEK_APP_ID)
        }
        
        return appId
    }

    //MARK: - AppStore Check
    mutating func setLastAppStoreCheck(){
        let date = NSDate()
        userdefaults.setObject(date, forKey: LEK_LAST_APPSTORE_CHECK)
        userdefaults.synchronize()
        
        self.config.lastAppStoreCheck = date
    }
    
    func getLastAppStoreCheck()->NSDate? {
        let date = userdefaults.objectForKey(LEK_LAST_APPSTORE_CHECK) as? NSDate
        return date
    }
    
    //MARK: - Install Date
    mutating func setInstalledDate() {
        let date = NSDate()
        userdefaults.setObject(date, forKey: LEK_INSTALL_DATE)
        userdefaults.synchronize()
        
        self.config.installDate = date
    }
    
    func getInstalledDate() ->NSDate?{
        let date = userdefaults.objectForKey(LEK_INSTALL_DATE) as? NSDate
        return date
    }
    
    //MARK: - Ratings
    mutating func setLaunchesBeforeRating(launches: Int){
        userdefaults.setInteger(launches, forKey: LEK_REQUIRED_LAUNCHES_BEFORE_RATING)
        userdefaults.synchronize()
        
        self.config.requiredAppLaunchesBeforeRatingsCheck = launches
    }
    
    func getLaunchesRequiredBeforeRating()->Int{
        let launches = userdefaults.integerForKey(LEK_REQUIRED_LAUNCHES_BEFORE_RATING) ?? 0
        return launches
    }
    
    mutating func setLastRatingsCheck() {
        let date = NSDate()
        userdefaults.setObject(date, forKey: LEK_LAST_RATINGS_CHECK_DATE)
        userdefaults.synchronize()
        
        self.config.lastRatingsCheckDate = date
    }
    
    func getLastRatingsCheckDate()->NSDate?{
        let date = userdefaults.objectForKey(LEK_LAST_RATINGS_CHECK_DATE) as? NSDate
        return date
    }
    
    //MARK: - App Version
    mutating func setLaunchesBeforeCheckingAppVersion(launches: Int){
        userdefaults.setInteger(launches, forKey: LEK_REQUIRED_LAUNCHES_BEFORE_APPVERSION)
        userdefaults.synchronize()
        self.config.requiredAppLaunchesBeforeUpdateCheck = launches
    }
    
    func getLaunchesBeforeCheckingAppVersion()->Int{
        let launches = userdefaults.integerForKey(LEK_REQUIRED_LAUNCHES_BEFORE_APPVERSION) ?? 0
        return launches
    }
}