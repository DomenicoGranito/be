//
//  BENavigationController.swift
//  BEINIT
//
//  Created by Macmini on 6/10/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class BENavigationController: UINavigationController
{
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let supportedOrientations = self.topViewController?.supportedInterfaceOrientations {
            return supportedOrientations
        }else{
            return .portrait
        }
    }
    
    override var shouldAutorotate: Bool {
        if let shouldrotate = self.topViewController?.shouldAutorotate {
            return shouldrotate
        }else{
            return false
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        if let prefferedOrientation = self.topViewController?.preferredInterfaceOrientationForPresentation {
            return prefferedOrientation
        }else{
            return .portrait
        }
    }
}
