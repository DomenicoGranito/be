//
//  TabBarViewController.swift
//  BEINIT
//
//  Created by Dominic Granito on 29/12/2016.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

import Photos

class TabBarViewController: UITabBarController, UITabBarControllerDelegate
{
    @IBOutlet var vtabBar:UITabBar!
    @IBOutlet var miniPlayerView:UIView!
    @IBOutlet var videoTitleLbl:UILabel!
    @IBOutlet var videoArtistLbl:UILabel!
    @IBOutlet var videoThumbnailImageView:UIImageView!
    @IBOutlet var backgroundImageView:UIImageView!
    @IBOutlet var seekBar:UISlider!
    
    var animator:ARNTransitionAnimator!
    var modalVC:ModalViewController!
    let (host, _, _, _, _)=Config.shared.wowza()
    
    override func viewDidLoad()
    {
        seekBar.setThumbImage(UIImage(), for:.normal)
        
        miniPlayerView.frame=CGRect(x:0, y:view.frame.size.height-99, width:view.frame.size.width, height:50)
        view.addSubview(miniPlayerView)
        miniPlayerView.isHidden=true
        
        getPermissions()
        
        NotificationCenter.default.addObserver(self, selector:#selector(goToChannels), name:Notification.Name("goToChannels"), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(hideMiniPlayer), name:Notification.Name("hideMiniPlayer"), object:nil)
    }
        
    func hideMiniPlayer()
    {
        miniPlayerView.isHidden=true
    }
    
    func updateSeekBar(_ current:Float, _ maximum:Float)
    {
        seekBar.maximumValue=maximum
        seekBar.value=current
    }
    
    func updateMiniPlayerWithStream(_ stream:Stream)
    {
        miniPlayerView.isHidden=false
        
        videoTitleLbl.text=stream.title
        videoArtistLbl.text=stream.user.name
        videoThumbnailImageView.sd_setImage(with: URL(string:"http://\(host)/thumb/\(stream.id).jpg"))
        backgroundImageView.sd_setImage(with: URL(string:"http://\(host)/thumb/\(stream.id).jpg"))
    }
    
    func configure(_ stream:Stream)
    {
        setupAnimator()
        updateMiniPlayerWithStream(stream)
        tapMiniPlayerButton()
    }
    
    func goToChannels(notification:Notification)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewController(withIdentifier: "UserViewControllerId") as! UserViewController
        vc.user=notification.object as? User
        
        let navigationController=self.viewControllers![self.selectedIndex] as! UINavigationController
        navigationController.pushViewController(vc, animated:true)
    }
    
    @IBAction func tapMiniPlayerButton()
    {
        present(modalVC, animated:true, completion:nil)
    }
    
    func tabBarController(_ tabBarController:UITabBarController, shouldSelect viewController:UIViewController)->Bool
    {
        let tabViewControllers=tabBarController.viewControllers
        let fromIndex=tabViewControllers?.index(of: tabBarController.selectedViewController!)
        
        UserDefaults.standard.set(fromIndex!, forKey:"previousTab")
        
        return true
    }
    
    func setupAnimator()
    {
        let animation=MusicPlayerTransitionAnimation(rootVC:self, modalVC:modalVC)
        
        animation.completion={isPresenting in
            if isPresenting
            {
                //let modalGestureHandler=TransitionGestureHandler(targetVC:self, direction:.bottom)
                //modalGestureHandler.registerGesture(self.modalVC.view)
                //modalGestureHandler.panCompletionThreshold=15.0
                //self.animator.registerInteractiveTransitioning(.dismiss, gestureHandler:modalGestureHandler)
            }
            else
            {
                self.setupAnimator()
            }
        }
        
        let gestureHandler=TransitionGestureHandler(targetVC:self, direction:.top)
        gestureHandler.registerGesture(miniPlayerView)
        gestureHandler.panCompletionThreshold=15.0
        
        animator=ARNTransitionAnimator(duration:0.5, animation:animation)
        animator.registerInteractiveTransitioning(.present, gestureHandler:gestureHandler)
        
        modalVC.transitioningDelegate=animator
    }
    
    func getPermissions()
    {
        if AVCaptureDevice.responds(to:#selector(AVCaptureDevice.requestAccess(forMediaType:completionHandler:)))
        {
            AVCaptureDevice.requestAccess(forMediaType:AVMediaTypeVideo, completionHandler:{(granted)->Void in})
        }
        
        if(AVAudioSession.sharedInstance().responds(to:#selector(AVAudioSession.requestRecordPermission(_:))))
        {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted:Bool)->Void in})
        }
        
        if NSClassFromString("PHPhotoLibrary") != nil
        {
            PHPhotoLibrary.requestAuthorization{(status)->Void in}
        }
    }
}
