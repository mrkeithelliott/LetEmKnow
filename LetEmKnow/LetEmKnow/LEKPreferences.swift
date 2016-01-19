//
//  LEKPreferences.swift
//  LetEmKnow
//
//  Created by Keith Elliott on 1/19/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import Foundation

let LEK_APP_LAUNCHES = "com.gittielabs.applaunches"

public struct LEKPreferences {
    let userdefaults = NSUserDefaults()
    
    func incrementAppLaunches(){
        var launches = userdefaults.integerForKey(LEK_APP_LAUNCHES)
        launches++
        userdefaults.setInteger(launches, forKey: LEK_APP_LAUNCHES)
        userdefaults.synchronize()
    }
    
    func getAppLaunchCount() -> Int {
        let launches = userdefaults.integerForKey(LEK_APP_LAUNCHES)
        return launches
    }
}