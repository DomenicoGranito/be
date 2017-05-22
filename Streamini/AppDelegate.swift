//
//  AppDelegate.swift
//  Streamini
//
//  Created by Vasily Evreinov on 17/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate
{
    var shouldRotate=false
    var window: UIWindow?
    var deviceToken: String?
    var notificationsDelegate = NotificationsDelegate()
    var bgTask: UIBackgroundTaskIdentifier?
    var closeStream: Bool = false
    var reachability:Reachability!

    //dominicg weixin login wx68aa08d12b601234 dgranito@gmail account
    //wx282a923ebe81d445 demo account
    //AppID：wx5bd67c93b16ab684 marie@cedricm.com account
    //wxa0bd27aed1120e15 testing account login
        
    var documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    // this will be used when opening Webview from playlist
    var downloadTable : downloadTableViewControllerDelegate?
    var dataDownloader : DataDownloader?
    
    fileprivate func addCustomMenuItems()
    {
        let menuController = UIMenuController.shared
        var menuItems = menuController.menuItems ?? [UIMenuItem]()
        
        let copyLinkItem = UIMenuItem(title: "Copy Link", action: MenuAction.copyLink.selector())
        let saveVideoItem = UIMenuItem(title: "Save to Camera Roll", action: MenuAction.saveVideo.selector())
        
        menuItems.append(copyLinkItem)
        menuItems.append(saveVideoItem)
        menuController.menuItems = menuItems
    }
    
    func application(_ application:UIApplication, supportedInterfaceOrientationsFor window:UIWindow?)->UIInterfaceOrientationMask
    {
        if shouldRotate
        {
            return .allButUpsideDown
        }
        else
        {
            return .portrait
        }
    }
    
    func applicationWillResignActive(_ application:UIApplication)
    {
        if(closeStream)
        {
            // Post notifications to current controllers
            NotificationCenter.default.post(name:Notification.Name("Close/Leave"), object:nil)
            
            // Dismiss all view controllers behind MainViewController
            let root = UIApplication.shared.delegate!.window!?.rootViewController as! UINavigationController
            
            if root.topViewController!.presentedViewController != nil {
                root.topViewController!.presentedViewController!.dismiss(animated: false, completion: nil)
            }
            
            let controllers = root.viewControllers.filter({ ($0 is LoginViewController)})
            root.setViewControllers(controllers, animated: false)
            
            self.bgTask = application.beginBackgroundTask(withName: "Disconnect Live Stream", expirationHandler: { () -> Void in
                application.endBackgroundTask(self.bgTask!)
                self.bgTask = UIBackgroundTaskInvalid
            })
        }
    }
    
    func applicationDidEnterBackground(_ application:UIApplication)
    {
        NotificationCenter.default.post(name:Notification.Name("enteredBackgroundID"), object:nil)
    }
    
    func applicationWillEnterForeground(_ application:UIApplication)
    {
        NotificationCenter.default.post(name:Notification.Name("enteredForegroundID"), object:nil)
    }
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        let cacheFolder = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        var dirsToClean : [String] = []
        
        dirsToClean += [(cacheFolder as NSString).appendingPathComponent("/com.uniprogy.dominic/fsCachedData/"),
                        (cacheFolder as NSString).appendingPathComponent("/com.apple.nsurlsessiond/"),
                        (cacheFolder as NSString).appending("/WebKit/"),
                        NSTemporaryDirectory()]
        
        for dir : String in dirsToClean{
            MiscFuncs.deleteFiles(dir)
        }
        
        self.saveContext()
    }
    
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        let modelURL = Bundle.main.url(forResource: "Music_Player", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Music_Player.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    func application(_ application:UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplicationLaunchOptionsKey:Any]?)->Bool
    {
        reachability=Reachability()
        
        NotificationCenter.default.addObserver(self, selector:#selector(reachabilityChanged), name:ReachabilityChangedNotification, object:nil)
        
        try! reachability.startNotifier()

        addCustomMenuItems()
           
        UITextField.appearance().tintColor=UIColor(colorLiteralRed:43/255, green:185/255, blue:86/255, alpha:1)
        UITextField.appearance().keyboardAppearance = .dark
        
        RestKitObjC.setupLog()
        
        registerForNotification()
        
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated:true)
        
        UINavigationBar.setCustomAppereance()
        
        UserDefaults.standard.removeObject(forKey: "isGlobalStreamsInMain")
        
        return true
    }

    func reachabilityChanged()
    {
        NotificationCenter.default.post(name:Notification.Name("status"), object:nil)
    }

    func applicationDidBecomeActive(_ application:UIApplication)
    {
       if let task = self.bgTask {
            if (task != UIBackgroundTaskInvalid)
            {
               UIApplication.shared.endBackgroundTask(task)
                self.bgTask = UIBackgroundTaskInvalid;
            }
        }
        
       NotificationCenter.default.post(name:Notification.Name("Open"), object:nil)
    }
    
    func registerForNotification()
    {
        let application = UIApplication.shared
        
        if #available(iOS 8.0, *) {
                let types:UIUserNotificationType = ([.alert, .badge, .sound])
                let settings:UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
        } else {
            // Register for Push Notifications before iOS 8
            application.registerForRemoteNotifications(matching: [.alert, .badge, .sound])
        }
    }
    
    func application(_ application:UIApplication, didReceiveRemoteNotification userInfo:[AnyHashable:Any], fetchCompletionHandler completionHandler:(UIBackgroundFetchResult)->Void)
    {
        completionHandler(UIBackgroundFetchResult.noData)
        
        if !UserContainer.shared.isLogged() {
            return
        }
        
        let uid = userInfo["uni-rcpt"] as! UInt
        if uid != UserContainer.shared.logged().id {
            return
        }
        
        let type = userInfo["uni-type"] as! UInt
        
        let name =
        (((userInfo["aps"] as! NSDictionary)["alert"] as! NSDictionary)["loc-args"] as! NSArray)[0] as! String
        
        if type == 1 && name == UserContainer.shared.logged().name {
            return
        }
        
        notificationsDelegate.streamId = userInfo["uni-id"] as? UInt
        UIAlertView.notificationAlert(notificationsDelegate, userInfo: userInfo).show()
    }
    
    func application(_ application:UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken:NSData)
    {
        /* Each byte in the data will be translated to its hex value like 0x01 or
        0xAB excluding the 0x part, so for 1 byte, we will need 2 characters to
        represent that byte, hence the * 2 */
        let tokenAsString = NSMutableString()
        
        /* Create a buffer of UInt8 values and then get the raw bytes
        of the device token into this buffer */
        var byteBuffer = [UInt8](repeating: 0x00, count: deviceToken.length)
        deviceToken.getBytes(&byteBuffer)
        
        /* Now convert the bytes into their hex equivalent */
        for byte in byteBuffer {
            tokenAsString.appendFormat("%02hhX", byte)
        }
        
        self.deviceToken = tokenAsString as String
    }
    
    func application(_ application:UIApplication, didFailToRegisterForRemoteNotificationsWithError error:NSError)
    {
        NSLog("%@",error.localizedDescription)
    }
    
    func application(_ application:UIApplication, handleOpen url:URL)->Bool
    {
        return WXApi.handleOpen(url as URL!, delegate:self)
    }
    
    func onResp(_ resp:BaseResp)
    {
        if let authResp=resp as? SendAuthResp
        {
            if authResp.code != nil
            {
                NotificationCenter.default.post(name:Notification.Name("getCode"), object:authResp.code)
            }
            else
            {
                errorAlert()
            }
        }
        else
        {
            errorAlert()
        }
    }
    
    func errorAlert()
    {
        SCLAlertView().showSuccess("ERROR", subTitle:"Failed to get response")
    }
}
