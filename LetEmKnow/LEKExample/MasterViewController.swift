//
//  MasterViewController.swift
//  LEKExample
//
//  Created by Keith Elliott on 1/11/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import UIKit
import LetEmKnow

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newToastReceived:", name: LEK_NEW_TOAST_NOTIFICATION, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        
//        let lek = LEKManager(mainWindow: UIApplication.sharedApplication().windows[0])
//        lek.sendToast("Test Title", message: "Test message and such", icon: nil)
//        lek.sendToast("Test Toast Title", message: "Test toast message with a really long explanation of really nothing at all.  Hopefully multilines", backgroundColor: UIColor.redColor(),titleColor: UIColor.whiteColor(), textColor: UIColor.whiteColor(), icon: nil)
//        lek.sendToast("Test Toast Title", message: "Test toast message with a really long explanation of really nothing at all.  Hopefully multilines", delayInSeconds: 3, backgroundColor: UIColor.redColor(),titleColor: UIColor.whiteColor(), textColor: UIColor.whiteColor(), icon: nil)
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(2) * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(LEK_NEW_TOAST_NOTIFICATION, object: nil, userInfo: ["toast" : ["title": "Test Toast Message", "message": "Test toast message with a really long explanation of really nothing at all.  Hopefully multilines", "icon": "https://test.com/icon", "backgroundColor": "#808080",
                "textColor": "white", "titleColor": "ffffff"]])

        })

       
    }
    
    func newToastReceived(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let toastDict = userInfo["toast"] as? NSDictionary,
            let toastObj: ToastMessage = ToastMessage.parse(toastDict){
                let lek = LEKManager(mainWindow: UIApplication.sharedApplication().windows[0])
                lek.sendToast(toastObj.title, message: toastObj.message, delayInSeconds: 3, backgroundColor: toastObj.backgroundColor,titleColor: toastObj.titleColor, textColor: toastObj.textColor, icon: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row] as! NSDate
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

