//
//  MusicPlayerTransitionAnimation.swift
//  MusicPlayerTransition
//
//  Created by xxxAIRINxxx on 2016/11/05.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import UIKit

final class MusicPlayerTransitionAnimation : TransitionAnimatable
{
    var rootVC:TabBarViewController!
    var playerVC:PlayerViewController!
    var completion:((Bool)->Void)?
    var miniPlayerStartFrame:CGRect
    var tabBarStartFrame:CGRect
    var containerView:UIView?
    
    func sourceVC()->UIViewController
    {
        return rootVC
    }
    
    func destVC()->UIViewController
    {
        return playerVC
    }
    
    init(rootVC:TabBarViewController, playerVC:PlayerViewController)
    {
        self.rootVC=rootVC
        self.playerVC=playerVC
        
        miniPlayerStartFrame=rootVC.miniPlayerView.frame
        tabBarStartFrame=rootVC.vtabBar.frame
    }
    
    func prepareContainer(_ transitionType:TransitionType, containerView:UIView, from fromVC:UIViewController, to toVC:UIViewController)
    {
        self.containerView=containerView
        
        rootVC.view.insertSubview(playerVC.view, belowSubview:rootVC.vtabBar)
    }
    
    func willAnimation(_ transitionType:TransitionType, containerView:UIView)
    {
        rootVC.beginAppearanceTransition(true, animated:false)
        
        if transitionType.isPresenting
        {
            playerVC.view.frame.origin.y=rootVC.miniPlayerView.frame.origin.y
        }
        else
        {
            rootVC.miniPlayerView.frame.origin.y=0
            rootVC.vtabBar.frame.origin.y=containerView.bounds.size.height
        }
    }
    
    func updateAnimation(_ transitionType:TransitionType, percentComplete:CGFloat)
    {
        if transitionType.isPresenting
        {
            let startOriginY=miniPlayerStartFrame.origin.y
            
            let tabStartOriginY=tabBarStartFrame.origin.y
            let tabEndOriginY=playerVC.view.frame.size.height
            let tabDiff=tabEndOriginY-tabStartOriginY
            
            let playerY=startOriginY-(startOriginY*percentComplete)
            rootVC.miniPlayerView.frame.origin.y=min(playerY, startOriginY)
            playerVC.view.frame.origin.y=min(playerY, startOriginY)
            
            let tabY=tabStartOriginY+(tabDiff*percentComplete)
            rootVC.vtabBar.frame.origin.y=max(tabY, tabStartOriginY)
            
            let alpha=1.0-(1.0*percentComplete)
            rootVC.vtabBar.alpha=alpha
            rootVC.miniPlayerView.alpha=alpha
        }
        else
        {
            let endOriginY=miniPlayerStartFrame.origin.y
            
            let tabStartOriginY=playerVC.view.frame.size.height
            let tabEndOriginY=tabBarStartFrame.origin.y
            let tabDiff=tabStartOriginY-tabEndOriginY
            
            rootVC.miniPlayerView.frame.origin.y=endOriginY*percentComplete
            playerVC.view.frame.origin.y=rootVC.miniPlayerView.frame.origin.y
            
            rootVC.vtabBar.frame.origin.y=tabStartOriginY-(tabDiff*percentComplete)
            
            let alpha=percentComplete
            rootVC.vtabBar.alpha=alpha
            rootVC.miniPlayerView.alpha=alpha
        }
    }
    
    func finishAnimation(_ transitionType:TransitionType, didComplete:Bool)
    {
        rootVC.endAppearanceTransition()
        
        if transitionType.isPresenting
        {
            if didComplete
            {
                playerVC.view.removeFromSuperview()
                containerView?.addSubview(playerVC.view)
                
                completion?(transitionType.isPresenting)
            }
            else
            {
                rootVC.beginAppearanceTransition(true, animated:false)
                rootVC.endAppearanceTransition()
            }
        }
        else
        {
            if didComplete
            {
                playerVC.view.removeFromSuperview()
                completion?(transitionType.isPresenting)
            }
            else
            {
                playerVC.view.removeFromSuperview()
                containerView?.addSubview(playerVC.view)
                
                rootVC.beginAppearanceTransition(false, animated:false)
                rootVC.endAppearanceTransition()
            }
        }
    }
}
