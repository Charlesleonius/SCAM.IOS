//
//  AppDelegate.swift
//  SCAM
//
//  Created by Charles Leon on 2/18/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import ExpandingMenu
import UserNotifications
import Haneke
import DropDown
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        DropDown.startListeningToKeyboard()
        IQKeyboardManager.sharedManager().enable = true
        
        //Push Notification Registration
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.sound, .badge]) { (granted, error) in
                if error == nil{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
        application.registerForRemoteNotifications()

        
        /******Parse Config*******/
        
        //Register Subclasses
        User.registerSubclass()
        Message.registerSubclass()
        ChatRoom.registerSubclass()
        ChatRoomObserver.registerSubclass()
        Group.registerSubclass()
        Post.registerSubclass()
        Profile.registerSubclass()
        
        //Enable Caching
        Parse.enableLocalDatastore()
        
        //Configure Server Ingo
        let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = "scam16"
            ParseMutableClientConfiguration.clientKey = "scamClientKey"
            ParseMutableClientConfiguration.server = "https://scam16.herokuapp.com/parse"
        })
        Parse.initialize(with: parseConfiguration)
        
        //Enable Auto-Login
        PFUser.enableAutomaticUser()
        
        //Default security for users (Only user and server have read or write access
        let defaultACL = PFACL();
        PFACL.setDefault(defaultACL, withAccessForCurrentUser: true)
        
        //Autlogin
        if (PFUser.current() != nil) {
            //If user session is no longer valid log them out
            PFSession.getCurrentSessionInBackground { (session: PFSession?, error: Error?) in
                if (session == nil) {
                    PFUser.logOut()
                    let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let rootView = storyboard.instantiateViewController(withIdentifier: "IntroViewController")
                    self.window?.rootViewController?.dismissKeyboard()
                    self.window?.rootViewController = rootView
                }
            }
            //Set initial view
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var rootView = storyboard.instantiateViewController(withIdentifier: "DashboardNavigationController")
            
            //If user has not filled in the required information then redirect them to the information input page
            if (!User.current()!.hasCompletedRequiredFields) {
                    rootView = storyboard.instantiateViewController(withIdentifier: "requiredProfileNavigationController")
            }
            
            //Set view
            self.window?.rootViewController?.dismissKeyboard()
            self.window?.rootViewController = rootView
            UIApplication.shared.statusBarStyle = .lightContent
        }
        
        return true
    }
    
    //--------------------------------------
    // Push Notifications
    //--------------------------------------
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        //Update installation or create new one
        let installation = PFInstallation.current()
        PFPush.storeDeviceToken(deviceToken)
        if (PFUser.current() != nil) {
            installation?["user"] = PFUser.current()!
        }
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground()
        UserDefaults.standard.set(deviceTokenString, forKey: "deviceToken")
        UserDefaults.standard.synchronize()
    }
    
    //Not currently being used but may be at some point
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications due to: " + error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        PFUser.current()?.fetchInBackground()
        if let aps = userInfo["aps"] as? NSDictionary {
            pushHandler(push: aps)
        }
    }
    
    func pushHandler(push: NSDictionary) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshRooms"), object: nil)
    }
    
    //For use at a later time

    func applicationWillResignActive(_ application: UIApplication) {
 
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
  
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

}

extension UIViewController {
    
    func configureExpandingMenuButton() {
        let menuButtonSize: CGSize = CGSize(width: 64.0, height: 64.0)
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), centerImage: #imageLiteral(resourceName: "menuButtonCircular"), centerHighlightedImage: #imageLiteral(resourceName: "menuButtonCircular"))
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        menuButton.center = CGPoint(x: screenWidth - 35.0, y: screenHeight - 35.0)
        menuButton.enabledExpandingAnimations = .MenuItemBound
        menuButton.enabledFoldingAnimations = .MenuItemBound
        self.view.addSubview(menuButton)
        
        if (!(self is ProfileTableViewController)) {
            let profile = ExpandingMenuItem(size: menuButtonSize, title: "Profile", image: #imageLiteral(resourceName: "profileMenuButton"), highlightedImage: #imageLiteral(resourceName: "profileMenuButton"), backgroundImage: nil, backgroundHighlightedImage: nil) { () -> Void in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileTableViewNavigationController")
                self.present(vc!, animated: true, completion: nil)
            }
            menuButton.addMenuItems([profile])
        }
        
        if (!(self is ChatRoomsViewController)) {
            let chats = ExpandingMenuItem(size: menuButtonSize, title: "Chats", image: #imageLiteral(resourceName: "chat"), highlightedImage: #imageLiteral(resourceName: "chat"), backgroundImage: nil, backgroundHighlightedImage: nil) { () -> Void in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DashboardNavigationController")
                self.present(vc!, animated: true, completion: nil)
            }
            menuButton.addMenuItems([chats])
        }
        
        if (!(self is GroupsCollectionViewController)) {
            let groups = ExpandingMenuItem(size: menuButtonSize, title: "Groups", image: #imageLiteral(resourceName: "groups"), highlightedImage: #imageLiteral(resourceName: "groups"), backgroundImage: nil, backgroundHighlightedImage: nil) { () -> Void in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupNavigationViewController")
                self.present(vc!, animated: true, completion: nil)
            }
            menuButton.addMenuItems([groups])
        }
        
        if (!(self is ConnectViewController)) {
            let connect = ExpandingMenuItem(size: menuButtonSize, title: "Connect", image: #imageLiteral(resourceName: "search"), highlightedImage: #imageLiteral(resourceName: "search"), backgroundImage: nil, backgroundHighlightedImage: nil) { () -> Void in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "connectNavigationViewController")
                self.present(vc!, animated: true, completion: nil)
            }
            menuButton.addMenuItems([connect])
        }
        
        menuButton.willPresentMenuItems = { (menu) -> Void in}
        
        menuButton.didDismissMenuItems = { (menu) -> Void in}
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

}

extension String {
    func insert(string:String,ind:Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
}

extension UIImageView {
    func loadFromChacheThenParse(file: PFFile, contentMode mode: UIViewContentMode = .scaleAspectFit, circular: Bool = false) {
        var url = file.url!
        if (!url.contains("https")) {
            url = url.insert(string: "s", ind: 4)
        }
        let URL = NSURL(string: url)!
        let cache = Shared.imageCache
        let fetcher = NetworkFetcher<UIImage>(URL: URL as URL)
        cache.fetch(fetcher: fetcher).onSuccess { image in
            DispatchQueue.main.async() { () -> Void in
                if (circular == true) {
                    self.image = image.circle
                } else {
                    self.image = image
                }
            }
        }
    }
}

extension UIImage {
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    var pngData: Data? { return UIImagePNGRepresentation(self) }
    
    func jpegData(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
    
    var rounded: UIImage? {
        let imageView = UIImageView(image: self)
        imageView.layer.cornerRadius = min(size.height/4, size.width/4)
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    var circle: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: square))
        imageView.contentMode = .scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

extension String {
    
    var length: Int {
        return self.characters.count
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return self[Range(start ..< end)]
    }
    
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

extension PFUser {
    
}
