//
//  LEKNetworkMgr.swift
//  LetEmKnow
//
//  Created by Keith Elliott on 1/19/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import Foundation
import Parse

public struct LEKNetworkManager{
    let session: NSURLSession
    
    init(){
        session = NSURLSession.sharedSession()
    }
    
    // MARK: - Checking New Messaging
    func checkForNewMessages(){
        let notification = ["toast": ""]
        NSNotificationCenter.defaultCenter().postNotificationName(LEK_NEW_TOAST_NOTIFICATION, object: nil, userInfo: notification)
        
    }
    
    func saveUpdates(){
        LEKManager.sharedInstance.preferences.config.synchronizeUser()
    }
    
    func checkForUpdates(){
        
    }
    
    // MARK: - Check for AppStore updates
    func checkForAppStoreUpdates(appId: String){
        let url = NSURL(string: "http://itunes.apple.com/lookup?id=\(appId)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error != nil{
                print("request failed")
            }
            else{
                do{
                    if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as? NSDictionary{
                        if let resultsArray = jsonDict.valueForKeyPath("results") as? NSArray{
                            if let result = resultsArray[0] as? NSDictionary {
                                if let appInfo = LEKAppInfo.parse(result){
                                    let userinfo = ["version": appInfo.version, "appId": appInfo.appId]
                                    NSNotificationCenter.defaultCenter().postNotificationName(LEK_APP_STORE_UPDATE_RETREIVED, object: nil, userInfo:userinfo)
                                }
                            }
                        }
                    }
                    
                }
                catch{
                    print("failed to serialize object to json")
                }
            }
        }
        
        task.resume()
    }
    
}