//
//  AppDelegate.swift
//  SCAM
//
//  Created by Charles Leon on 2/18/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Parse Config
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        Parse.enableLocalDatastore()
        let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = "scam16"
            ParseMutableClientConfiguration.clientKey = "scamClientKey"
            ParseMutableClientConfiguration.server = "https://scam16.herokuapp.com/parse"
        })
        
        Parse.initialize(with: parseConfiguration)
        PFUser.enableAutomaticUser()
        let defaultACL = PFACL();
        PFACL.setDefault(defaultACL, withAccessForCurrentUser: true)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

