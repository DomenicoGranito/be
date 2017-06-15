//
//  BETabBarController.swift
//  BEINIT
//
//  Created by Macmini on 6/10/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class BETabBarController: UITabBarController
{
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        if let _ = self.viewControllers?[selectedIndex], let supportedOrientations = self.selectedViewController?.supportedInterfaceOrientations{
            return supportedOrientations
        }else{
            return .portrait
        }
    }
    
    override var shouldAutorotate: Bool {
        if let _ = self.viewControllers?[selectedIndex], let shouldrotate = self.selectedViewController?.shouldAutorotate{
            return shouldrotate
        }else{
            return false
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        if let _ = self.viewControllers?[selectedIndex], let prefferedOrientation = self.selectedViewController?.preferredInterfaceOrientationForPresentation {
            return prefferedOrientation
        }else{
            return .portrait
        }
    }
}
