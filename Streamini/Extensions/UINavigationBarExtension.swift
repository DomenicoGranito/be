//
//  UINavigationBarExtension.swift
//  Streamini
//
//  Created by Vasily Evreinov on 29/09/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import Foundation

extension UINavigationBar
{
    class func setCustomAppereance()
    {
        UINavigationBar.appearance().shadowImage=UIImage()
        UINavigationBar.appearance().titleTextAttributes=[NSForegroundColorAttributeName:UIColor.white, NSFontAttributeName:UIFont.systemFont(ofSize:15)]
        UINavigationBar.appearance().isTranslucent=true
        UINavigationBar.appearance().barTintColor=UIColor.clear
        UINavigationBar.appearance().backgroundColor=UIColor.black
    }
    
    class func resetCustomAppereance()
    {
        UINavigationBar.appearance().tintColor=nil
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for:.default)
        UINavigationBar.appearance().shadowImage=nil
        UINavigationBar.appearance().titleTextAttributes=nil
    }
}
