//
//  TabBarController.swift
//  Music Player
//
//  Created by Samuel Chu on 1/3/16.
//  Copyright © 2016 Sem. All rights reserved.
//

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    //disable pop to root view controller
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return viewController != tabBarController.selectedViewController
    }
}
