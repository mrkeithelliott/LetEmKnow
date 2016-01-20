//
//  LEKNetworkMgr.swift
//  LetEmKnow
//
//  Created by Keith Elliott on 1/19/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import Foundation

public struct LEKNetworkManager{
    let session: NSURLSession
    var _rootURL: NSURL! = nil
    
    init(rootURL: String?){
        session = NSURLSession.sharedSession()
        if let url = NSURL(string: rootURL!){
            _rootURL = url
        }
    }
    
    func checkForNewMessages(){
        if _rootURL == nil {
            return
        }
        
        let request = NSMutableURLRequest(URL: self._rootURL)
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error != nil{
                print("request failed", terminator: "")
            }
            else{
                do{
                    if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as? NSDictionary{
                        if let result = jsonDict.valueForKeyPath("result") as? NSDictionary {
                            let notification = ["toast": result]
                            NSNotificationCenter.defaultCenter().postNotificationName(LEK_NEW_TOAST_NOTIFICATION, object: nil, userInfo: notification)
                        }
                    }
                    
                }
                catch{
                    print("failed to serialize object to json", terminator: "")
                }
            }
        }
        
        task.resume()
    }
    
    func saveUpdates(){
        
    }
    
    func checkForUpdates(){
        
    }
    
    func checkForAppStoreUpdates(appId: String){
        let url = NSURL(string: "http://itunes.apple.com/lookup?id=\(appId)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error != nil{
                print("request failed", terminator: "")
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
                    print("failed to serialize object to json", terminator: "")
                }
            }
        }
        
        task.resume()
    }
    
}