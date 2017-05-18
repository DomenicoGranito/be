//
//  ARNImageTransitionNavigationController.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
//import ARNVTransitionAnimator

class ARNImageTransitionNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    
    //let interactiveAnimator : ARNVTransitionAnimator
    weak var interactiveAnimator : ARNVTransitionAnimator?
    var currentOperation : UINavigationControllerOperation = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactivePopGestureRecognizer?.isEnabled = false
        self.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationControllerOperation,
        from fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        self.currentOperation = operation
        
        if let interactiveAnimator = self.interactiveAnimator {
            return interactiveAnimator
        }
        
        if operation == .push {
            return ARNImageZoomTransition.createAnimator(.push, fromVC: fromVC, toVC: toVC)
        } else if operation == .pop {
            return ARNImageZoomTransition.createAnimator(.pop, fromVC: fromVC, toVC: toVC)
        }
        
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let interactiveAnimator = self.interactiveAnimator {
            if  self.currentOperation == .pop {
                return interactiveAnimator
            }
        }
        return nil
    }
}
