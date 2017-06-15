//
//  GetStartedViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 8/27/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class GetStartedViewController: BaseViewController
{
    @IBOutlet var pageControl:UIPageControl?
    @IBOutlet var titleLbl:UILabel?
    @IBOutlet var descriptionLbl:UILabel?
    
    var backgroundPlayer:BackgroundVideo?
    let titlesArray=["Beinit.Live","Discover","Stream Live Events","Search","Connect"]
    let descriptionsArray=["Connecting & Live Streaming the World of Premium Events in Asia", "Premium Events Playlists, Fashion Show Collections, Live Streaming Concerts", "Experience VR Live Stream with front row seating", "Find Agencies, Brands, Venues, Celebrities and Entertainment Talents", "Connect with industry professionals, talents and Premium Agencies."]
    var count=0
    var timer:Timer?
    
    override func viewDidLoad()
    {
        backgroundPlayer=BackgroundVideo(onViewController:self, withVideoURL:"test.mp4")
        backgroundPlayer?.setUpBackground()
        
        titleLbl?.text=titlesArray[count]
        descriptionLbl?.text=descriptionsArray[count]
        
        timer=Timer.scheduledTimer(timeInterval: 5, target:self, selector:#selector(GetStartedViewController.swipeLeft), userInfo:nil, repeats:true)
        
        let swipeLeft=UISwipeGestureRecognizer(target:self, action:#selector(swipe))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight=UISwipeGestureRecognizer(target:self, action:#selector(swipe))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        if let _=A0SimpleKeychain().string(forKey:"PHPSESSID")
        {
            UserConnector().get(nil, successUser, forgotFailure)
            UserContainer.shared.setLogged(SongManager.getLogin())
            
            let vc=storyBoard.instantiateViewController(withIdentifier:"TabBarViewController")
            navigationController?.pushViewController(vc, animated:false)
        }
    }
    
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask
    {
        return .portrait
    }
    
    override var shouldAutorotate:Bool
    {
        return false
    }
    
    func successUser(user:User)
    {
        SongManager.updateLogin(user)
        UserContainer.shared.setLogged(user)
    }

    func forgotFailure(error:NSError)
    {
        handleError(error)
    }

    func swipe(_ recognizer:UISwipeGestureRecognizer)
    {
        if(recognizer.direction == .left)
        {
            timer?.invalidate()
            swipeLeft()
        }
        if(recognizer.direction == .right)
        {
            timer?.invalidate()
            swipeRight()
        }
        if(recognizer.state == .ended)
        {
            timer=Timer.scheduledTimer(timeInterval: 5, target:self, selector:#selector(swipeLeft), userInfo:nil, repeats:true)
        }
    }
    
    func swipeLeft()
    {
        count += 1
        
        if(count>4)
        {
            count=0
        }
        
        pageControl?.currentPage=count
        
        titleLbl?.text=titlesArray[count]
        descriptionLbl?.text=descriptionsArray[count]
    }
    
    func swipeRight()
    {
        count -= 1
        
        if(count<0)
        {
            count=4
        }
        
        pageControl?.currentPage=count
        
        titleLbl?.text=titlesArray[count]
        descriptionLbl?.text=descriptionsArray[count]
    }
}
