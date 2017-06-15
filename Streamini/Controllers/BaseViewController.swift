//
//  BaseViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class BaseViewController: UIViewController
{
    let storyBoard=UIStoryboard(name:"Main", bundle:nil)
    
    func handleError(_ error:NSError)
    {
        if let userInfo=error.userInfo as? [String:NSObject]
        {
            let code=error.code
            
            if code == CustomError.kLoginExpiredCode
            {
                let root=UIApplication.shared.delegate!.window!?.rootViewController as! UINavigationController
                
                if root.topViewController!.presentedViewController != nil
                {
                    root.topViewController!.presentedViewController!.dismiss(animated: true, completion:nil)
                }
                
                let controllers=root.viewControllers.filter({($0 is LoginViewController)})
                root.setViewControllers(controllers, animated:true)
                
                let message=userInfo[NSLocalizedDescriptionKey] as! String
                let alertView=UIAlertView.notAuthorizedAlert(message)
                alertView.show()
            }
            else
            {
                let message=userInfo[NSLocalizedDescriptionKey] as! String
                let alertView=UIAlertView.notAuthorizedAlert(message)
                alertView.show()
            }
        }
    }
}
