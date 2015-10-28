//
//  AppDelegate.swift
//  buscaconcurso
//
//  Created by Guilherme Leite Colares on 10/16/15.
//  Copyright © 2015 Guilherme Leite Colares. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.enableLocalDatastore()
        Parse.setApplicationId("APPLICATION_ID",
            clientKey: "CLIENT_ID")
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        if UIApplication.instancesRespondToSelector("registerUserNotificationSettings:") {
            let types = UIUserNotificationType([.Alert, .Badge, .Sound])
            
            UIApplication.sharedApplication().registerUserNotificationSettings(
                UIUserNotificationSettings(forTypes: types, categories: nil))
        }
        application.registerForRemoteNotifications()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        UIApplication.sharedApplication().applicationIconBadgeNumber =  0
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        let concourse = notification.userInfo
        NSNotificationCenter.defaultCenter().postNotificationName("showConcourse", object: nil, userInfo: concourse)
        
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current Installation and save it to Parse
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        
        var date = userDefault.objectForKey("date") as? NSDate
        if date == nil {
            date = NSDate()
        }
        date = date!.toUTC()
        let cache = PFQuery(className: "region")
        cache.fromPinWithName("regionsSelected")
        cache.findObjectsInBackgroundWithBlock { (regions, error) -> Void in
            let queryConcourse = PFQuery(className: "concourse").orderByDescending("createdAt")
            queryConcourse.includeKey("region")
            queryConcourse.whereKey("createdAt", greaterThan: date!)
            if let regions = regions {
                if regions.count > 0 {
                    queryConcourse.whereKey("region", containedIn: regions)
                }
            }
            
            queryConcourse.findObjectsInBackgroundWithBlock({ (concourses, error) -> Void in
                if error == nil {
                    if concourses!.count  > 0{
                        for concourse in concourses! {
                            let concoursePart = concourse["part"] as! String
                            let position = concourse["position"] as! String
                            let text = "Concurso \(concoursePart) com \(position) vagas."
                            let localNotification = UILocalNotification()
                            localNotification.fireDate = nil
                            localNotification.userInfo = ["concourse" : concourse.objectId!]
                            localNotification.alertBody = text
                            localNotification.timeZone = NSTimeZone.defaultTimeZone()
                            localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
                            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                        }
                        completionHandler(.NewData)
                    
                    }else{
                        completionHandler(.NoData)
                    }
                }else{
                    completionHandler(.NoData)
                }
            })
        }
    }
    
    
}

