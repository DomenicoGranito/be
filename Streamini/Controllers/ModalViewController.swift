//
//  ModalViewController.swift
//  MusicPlayerTransition
//
//  Created by xxxAIRINxxx on 2015/02/25.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

class ModalViewController: UIViewController, ARNImageTransitionZoomable
{
    @IBOutlet var carousel:iCarousel?
    @IBOutlet var backgroundImageView:UIImageView?
    @IBOutlet var headerTitleLbl:UILabel?
    @IBOutlet var videoTitleLbl:UILabel?
    @IBOutlet var videoArtistNameLbl:UILabel?
    @IBOutlet var videoProgressDurationLbl:UILabel?
    @IBOutlet var videoDurationLbl:UILabel?
    @IBOutlet var likeButton:UIButton?
    @IBOutlet var playButton:UIButton?
    @IBOutlet var playlistButton:UIButton?
    @IBOutlet var closeButton:UIButton?
    @IBOutlet var seekBar:UISlider?
    @IBOutlet var previousButton:UIButton?
    @IBOutlet var nextButton:UIButton?
    @IBOutlet var shuffleButton:UIButton?
    @IBOutlet var bottomSpaceConstraint:NSLayoutConstraint?
    @IBOutlet var informationView:UIView?
    @IBOutlet var topView:UIView?
    
    var isPlaying=true
    var TBVC:TabBarViewController!
    var player:DWMoviePlayerController?
    var stream:Stream?
    var streamsArray:NSArray?
    let (host, port, _, _, _)=Config.shared.wowza()
    var videoIDs:[String]=[]
    var timer:Timer?
    var selectedItemIndex=0
    var appDelegate:AppDelegate!
    var fullScreenButton:UIButton!
    let storyBoard=UIStoryboard(name:"Main", bundle:nil)
    
    override func viewDidLoad()
    {
        seekBar!.setThumbImage(UIImage(), for:.normal)
        
        appDelegate=UIApplication.shared.delegate as! AppDelegate
        
        stream=streamsArray!.object(at:selectedItemIndex) as? Stream
        
        NotificationCenter.default.addObserver(self, selector:#selector(onDeviceOrientationChange), name:.UIDeviceOrientationDidChange, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(deleteBlockUserVideos), name:Notification.Name("blockUser"), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(updatePlayer), name:Notification.Name("updatePlayer"), object:nil)
        
        createPlaylist()
        updatePlayerWithStream()
        
        if streamsArray!.count>1
        {
            carousel?.isPagingEnabled=true
            carousel?.type = .rotary
            
            carousel?.scrollToItem(at:selectedItemIndex, animated:false)
        }
        else
        {
            carousel?.isScrollEnabled=false
        }
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        UIApplication.shared.setStatusBarHidden(true, with:.fade)
        
        songLikeStatus()
        
        appDelegate.shouldRotate=true
    }
    
    override func viewDidAppear(_ animated:Bool)
    {
        if isPlaying
        {
            player?.play()
            
            playButton?.setImage(UIImage(named:"big_pause_button"), for:.normal)
        }
        else
        {
            player?.pause()
            
            playButton?.setImage(UIImage(named:"big_play_button"), for:.normal)
        }
    }
    
    override func viewWillDisappear(_ animated:Bool)
    {
        player?.shouldAutoplay=false
        player?.pause()
        
        TBVC.updateSeekBar(seekBar!.value, seekBar!.maximumValue)
        appDelegate.shouldRotate=false
    }
    
    func updatePlayer(notification:Notification)
    {
        selectedItemIndex=notification.object as! Int
        updateButtons()
        videoIDs.removeAll()
        createPlaylist()
    }
    
    func deleteBlockUserVideos()
    {
        let blockedUserID=stream!.user.id
        let streamsMutableArray=NSMutableArray(array:streamsArray!)
        
        for i in 0 ..< streamsArray!.count
        {
            let stream=streamsArray![i] as! Stream
            
            if blockedUserID==stream.user.id
            {
                streamsMutableArray.remove(stream)
                
                let index=videoIDs.index(of:stream.videoID)
                videoIDs.remove(at:index!)
            }
        }
        
        streamsArray=streamsMutableArray
        
        if streamsArray!.count==0
        {
            close()
        }
        else
        {
            carousel!.reloadData()
        }
    }
    
    func updatePlayerWithStream()
    {
        backgroundImageView?.sd_setImage(with:URL(string:"http://\(host)/thumb/\(stream!.id).jpg"))
        
        headerTitleLbl?.text=stream?.title
        videoTitleLbl?.text=stream?.title
        videoArtistNameLbl?.text=stream?.user.name
        
        SongManager.addToRecentlyPlayed(stream!.title, stream!.streamHash, stream!.id, stream!.user.name, stream!.videoID, stream!.user.id)
        
        songLikeStatus()
    }
    
    func songLikeStatus()
    {
        if SongManager.isAlreadyFavourited(stream!.id)
        {
            likeButton?.setImage(UIImage(named:"red_heart"), for:.normal)
        }
        else
        {
            likeButton?.setImage(UIImage(named:"empty_heart"), for:.normal)
        }
    }
    
    func createPlaylist()
    {
        for i in 0 ..< streamsArray!.count
        {
            let stream=streamsArray![i] as! Stream
            
            videoIDs.append(stream.videoID)
        }
    }
    
    func addPlayer()
    {
        seekBar?.value=0
        videoProgressDurationLbl?.text="0:00"
        videoDurationLbl?.text="-0:00"
        
        player=DWMoviePlayerController(userId:"D43560320694466A", key:"WGbPBVI3075vGwA0AIW0SR9pDTsQR229")
        player?.controlStyle = .none
        player?.scalingMode = .aspectFit
        
        NotificationCenter.default.addObserver(self, selector:#selector(moviePlayerDurationAvailable), name:.MPMovieDurationAvailable, object:player!)
        
        timer=Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(timerHandler), userInfo:nil, repeats:true)
    }
    
    func timerHandler()
    {
        videoDurationLbl?.text="-\(secondsToReadableTime(player!.duration-player!.currentPlaybackTime))"
        videoProgressDurationLbl?.text=secondsToReadableTime(player!.currentPlaybackTime)
        seekBar?.value=Float(player!.currentPlaybackTime)
    }
    
    func moviePlayerDurationAvailable()
    {
        videoDurationLbl?.text="-\(secondsToReadableTime(player!.duration))"
        seekBar?.maximumValue=Float(player!.duration)
        
        player!.view.isHidden=false
    }
    
    @IBAction func shuffle()
    {
        selectedItemIndex=Int(arc4random_uniform(UInt32(streamsArray!.count)))
        
        carousel?.scrollToItem(at:selectedItemIndex, animated:true)
    }
    
    @IBAction func previous()
    {
        selectedItemIndex=streamsArray!.index(of:stream!)-1
        
        carousel?.scrollToItem(at:selectedItemIndex, animated:true)
    }
    
    @IBAction func next()
    {
        selectedItemIndex=streamsArray!.index(of:stream!)+1
        
        carousel?.scrollToItem(at:selectedItemIndex, animated:true)
    }
    
    @IBAction func play()
    {
        if isPlaying
        {
            player?.pause()
            
            playButton?.setImage(UIImage(named:"big_play_button"), for:.normal)
            isPlaying=false
        }
        else
        {
            player?.play()
            
            playButton?.setImage(UIImage(named:"big_pause_button"), for:.normal)
            isPlaying=true
            
            if carousel!.currentItemView!.subviews.count==0
            {
                showPlayer()
            }
        }
    }
    
    func numberOfItemsInCarousel(_ carousel:iCarousel)->Int
    {
        return streamsArray!.count
    }
    
    func carouselItemWidth(_ carousel:iCarousel)->CGFloat
    {
        return view.frame.size.width-40
    }
    
    func carousel(_ carousel:iCarousel, viewForItemAtIndex index:Int, reusingView view:UIView?)->UIView
    {
        stream=streamsArray![index] as? Stream
        
        let thumbnailView=UIImageView(frame:CGRect(x:0, y:0, width:self.view.frame.size.width-5, height:self.view.frame.size.width-140))
        thumbnailView.backgroundColor=UIColor.darkGray
        thumbnailView.sd_setImage(with:URL(string:"http://\(host)/thumb/\(stream!.id).jpg"))
        
        return thumbnailView
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel:iCarousel)
    {
        carousel.reloadData()
    }
    
    func carousel(_ carousel:iCarousel, didSelectItemAtIndex index:Int)
    {
        play()
    }
    
    func carouselDidEndScrollingAnimation(_ carousel:iCarousel)
    {
        if streamsArray!.count>1
        {
            selectedItemIndex=carousel.currentItemIndex
            stream=streamsArray![selectedItemIndex] as? Stream
            
            TBVC.updateMiniPlayerWithStream(stream!)
            updateButtons()
            updatePlayerWithStream()
        }
        
        if isPlaying&&carousel.currentItemView!.subviews.count==0
        {
            showPlayer()
        }
    }
    
    func carousel(_ carousel:iCarousel, valueForOption option:iCarouselOption, withDefault value:CGFloat)->CGFloat
    {
        switch(option)
        {
        case .wrap:
            return 0
        case .showBackfaces:
            return 0
        case .spacing:
            return value*1.2
        case .visibleItems:
            return 3
        default:
            return value
        }
    }
    
    func showPlayer()
    {
        UIView.animate(withDuration:0.5, animations:{
            self.carousel!.currentItemView!.frame=CGRect(x:-20, y:0, width:self.view.frame.size.width, height:self.view.frame.size.width-140)
            }, completion:{(finished:Bool)->Void in
                self.addPlayerAtIndex()
        })
    }
    
    func addPlayerAtIndex()
    {
        timer?.invalidate()
        addPlayer()
        
        player!.view.frame=CGRect(x:0, y:0, width:view.frame.size.width, height:view.frame.size.width-140)
        player!.view.isHidden=true
        carousel!.currentItemView!.addSubview(player!.view)
        
        fullScreenButton=UIButton(frame:CGRect(x:view.frame.size.width-50, y:player!.view.frame.size.width-47, width:50, height:50))
        fullScreenButton.setImage(UIImage(named:"fullscreen"), for:.normal)
        fullScreenButton.addTarget(self, action:#selector(rotateScreen), for:.touchUpInside)
        view.insertSubview(fullScreenButton, aboveSubview:player!.view)
        
        if videoIDs[selectedItemIndex]==""
        {
            let label=UILabel(frame:CGRect(x:0, y:(view.frame.size.width-140)/2-10, width:view.frame.size.width, height:20))
            label.text="Video not available"
            label.textColor=UIColor.white
            label.textAlignment = .center
            player!.view.addSubview(label)
            
            playButton?.isEnabled=false
            playButton?.setImage(UIImage(named:"big_play_button"), for:.normal)
            
            return
        }
        
        player?.videoId=videoIDs[selectedItemIndex]
        player?.startRequestPlayInfo()
        player?.play()
        playButton?.isEnabled=true
        playButton?.setImage(UIImage(named:"big_pause_button"), for:.normal)
    }
    
    func rotateScreen()
    {
        let value=UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey:"orientation")
    }
    
    func onDeviceOrientationChange()
    {
        let orientation=UIApplication.shared.statusBarOrientation
        
        if UIInterfaceOrientationIsLandscape(orientation)
        {
            showLandscape()
        }
        else
        {
            showPortrait()
        }
    }
    
    func showLandscape()
    {
        informationView?.isHidden=true
        bottomSpaceConstraint!.constant=75
        player!.view.frame=CGRect(x:-(view.frame.size.width-view.frame.size.height)/2, y:-56, width:view.frame.size.width, height:view.frame.size.height)
        fullScreenButton.frame=CGRect(x:0, y:0, width:0, height:0)
        player?.scalingMode = .fill
        carousel?.isScrollEnabled=false
        view.bringSubview(toFront:topView!)
        playlistButton?.isHidden=true
        closeButton?.setImage(UIImage(named:"nonfullscreen"), for:.normal)
    }
    
    func showPortrait()
    {
        informationView?.isHidden=false
        bottomSpaceConstraint!.constant=0
        player!.view.frame=CGRect(x:0, y:0, width:view.frame.size.width, height:view.frame.size.width-140)
        fullScreenButton.frame=CGRect(x:view.frame.size.width-50, y:player!.view.frame.size.width-47, width:50, height:50)
        player?.scalingMode = .aspectFit
        playlistButton?.isHidden=false
        closeButton?.setImage(UIImage(named:"arrow_down"), for:.normal)
        
        if streamsArray!.count>1
        {
            carousel?.isScrollEnabled=true
        }
    }
    
    @IBAction func more()
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"PopUpViewController") as! PopUpViewController
        vc.stream=stream
        present(vc, animated:true)
    }
    
    @IBAction func like()
    {
        if SongManager.isAlreadyFavourited(stream!.id)
        {
            likeButton?.setImage(UIImage(named:"empty_heart"), for:.normal)
            SongManager.removeFromFavourite(stream!.id)
        }
        else
        {
            likeButton?.setImage(UIImage(named:"red_heart"), for:.normal)
            SongManager.addToFavourite(stream!.title, stream!.streamHash, stream!.id, stream!.user.name, stream!.vType, stream!.videoID, stream!.user.id)
        }
    }
    
    @IBAction func seekBarValueChanged()
    {
        player?.seekStartTime=player!.currentPlaybackTime
        player?.currentPlaybackTime=Double(seekBar!.value)
        
        videoProgressDurationLbl?.text=secondsToReadableTime(player!.currentPlaybackTime)
        videoDurationLbl?.text="-\(secondsToReadableTime(player!.duration-player!.currentPlaybackTime))"
    }
    
    @IBAction func close()
    {
        let orientation=UIApplication.shared.statusBarOrientation
        
        if UIInterfaceOrientationIsLandscape(orientation)
        {
            let value=UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey:"orientation")
        }
        else
        {
            UIApplication.shared.setStatusBarHidden(false, with:.fade)
            dismiss(animated:true)
        }
    }
    
    @IBAction func menu()
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"PlaylistViewController") as! PlaylistViewController
        vc.transitioningDelegate=vc
        vc.nowPlayingStreamIndex=selectedItemIndex
        vc.streamsArray=streamsArray as! NSMutableArray
        present(vc, animated:true)
    }
    
    func secondsToReadableTime(_ durationSeconds:Double)->String
    {
        if durationSeconds.isNaN
        {
            return "0:00"
        }
        
        let durationSeconds=Int(durationSeconds)
        
        var readableDuration=""
        
        let hours=durationSeconds/3600
        var minutes=String(format:"%02d", durationSeconds%3600/60)
        let seconds=String(format:"%02d", durationSeconds%3600%60)
        
        if(hours>0)
        {
            readableDuration="\(hours):"
        }
        else
        {
            minutes="\(Int(minutes)!)"
        }
        
        readableDuration+="\(minutes):\(seconds)"
        
        return readableDuration
    }
    
    func updateButtons()
    {
        nextButton?.isEnabled=true
        previousButton?.isEnabled=true
        shuffleButton?.isEnabled=true
        
        if selectedItemIndex==0
        {
            previousButton?.isEnabled=false
        }
        
        if selectedItemIndex==streamsArray!.count-1
        {
            nextButton?.isEnabled=false
        }
        
        if streamsArray!.count==1
        {
            shuffleButton?.isEnabled=false
        }
    }
    
    func createTransitionImageView()->UIImageView
    {
        return UIImageView()
    }
}
