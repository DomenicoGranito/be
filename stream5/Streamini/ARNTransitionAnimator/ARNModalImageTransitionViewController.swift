//
//  ARNModalImageTransitionViewController.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
//import ARNVTransitionAnimator

class ARNModalImageTransitionViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    weak var fromVC : UIViewController?

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = ARNImageZoomTransition.createAnimator(.present, fromVC: source, toVC: presented)
        self.fromVC = source
        
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = ARNImageZoomTransition.createAnimator(.dismiss, fromVC: self, toVC: self.fromVC!)
        
        return animator
    }
}
