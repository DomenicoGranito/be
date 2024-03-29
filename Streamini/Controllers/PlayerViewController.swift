//
//  PlayerViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 1/4/18.
//  Copyright © 2018 Cedricm Video. All rights reserved.
//

protocol RelatedVideoSelecting:class
{
    func updateRelatedVideosArray(_ videos:NSMutableArray)
    func relatedVideoDidSelected(_ index:Int)
}

class PlayerViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, RelatedVideoSelecting
{
    @IBOutlet var videoProgressDurationLbl:UILabel!
    @IBOutlet var videoDurationLbl:UILabel!
    @IBOutlet var seekBar:UISlider!
    @IBOutlet var playButton:UIButton!
    @IBOutlet var previousButton:UIButton!
    @IBOutlet var nextButton:UIButton!
    @IBOutlet var fullScreenButton:UIButton!
    @IBOutlet var relatedVideosTbl:UITableView!
    @IBOutlet var playerHeightConstraint:NSLayoutConstraint!
    
    var relatedVideosArray=NSMutableArray()
    var popularVideosArray=NSMutableArray()
    var isPlaying=true
    var TBVC:TabBarViewController!
    var player:DWMoviePlayerController!
    var stream:Stream!
    var appDelegate:AppDelegate!
    var page=0
    var timer:Timer!
    var selectedItemIndex=0
    var homeClassReference:HomeViewController?
    var categoryClassReference:CategoriesViewController?
    var channelClassReference:ChannelsViewController?
    var canExpand=true
    var layer:CAGradientLayer!
    
    override func viewDidLoad()
    {
        timer=Timer.scheduledTimer(timeInterval:5, target:self, selector:#selector(hideButtons), userInfo:nil, repeats:true)
        
        relatedVideosTbl.delegate=self
        relatedVideosTbl.dataSource=self
        
        let screenSize=UIScreen.main.bounds.height
        
        if screenSize==568
        {
            playerHeightConstraint.constant=227
        }
        else if screenSize==667
        {
            playerHeightConstraint.constant=267
        }
        else if screenSize==736
        {
            playerHeightConstraint.constant=294
        }
        else
        {
            playerHeightConstraint.constant=325
        }
        
        NotificationCenter.default.addObserver(self, selector:#selector(onDeviceOrientationChange), name:.UIDeviceOrientationDidChange, object:nil)
        
        appDelegate=UIApplication.shared.delegate as! AppDelegate
        
        relatedVideosTbl.addInfiniteScrolling{()->() in
            self.fetchMorePopularVideos()
        }
        
        StreamConnector().categoryStreams(false, true, stream.cid, 0, relatedVideosSuccess, failureStream)
        StreamConnector().categoryStreams(false, true, stream.cid, 0, popularVideosSuccess, failureStream)
        
        addPlayer()
    }
    
    override func viewDidAppear(_ animated:Bool)
    {
        appDelegate.shouldRotate=true
        
        UIApplication.shared.setStatusBarHidden(true, with:.slide)
        
        if isPlaying
        {
            player.play()
            
            playButton.setImage(UIImage(named:"big_pause_button"), for:.normal)
        }
        else
        {
            player.pause()
            
            playButton.setImage(UIImage(named:"big_play_button"), for:.normal)
        }
    }
    
    override func viewWillDisappear(_ animated:Bool)
    {
        player.shouldAutoplay=false
        player.pause()
        
        appDelegate.shouldRotate=false
    }
    
    func hideButtons()
    {
        previousButton.isHidden=true
        playButton.isHidden=true
        nextButton.isHidden=true
        fullScreenButton.isHidden=true
    }
    
    override func touchesBegan(_ touches:Set<UITouch>, with event:UIEvent?)
    {
        previousButton.isHidden=false
        playButton.isHidden=false
        nextButton.isHidden=false
        fullScreenButton.isHidden=false
        
        timer.invalidate()
        timer=Timer.scheduledTimer(timeInterval:5, target:self, selector:#selector(hideButtons), userInfo:nil, repeats:true)
    }
    
    func fetchMorePopularVideos()
    {
        page+=1
        StreamConnector().categoryStreams(false, true, stream.cid, page, fetchMorePopularVideosSuccess, failureStream)
    }
    
    func numberOfSections(in tableView:UITableView)->Int
    {
        return 3
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return section==2 ? popularVideosArray.count : 1
    }
    
    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return section==2 ? 30 : 1
    }
    
    func tableView(_ tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        if section<2
        {
            return nil
        }
        else
        {
            let headerView=UIView(frame:CGRect(x:0, y:0, width:view.frame.size.width, height:30))
            headerView.backgroundColor = .clear
            
            let titleLbl=UILabel(frame:CGRect(x:0, y:5, width:view.frame.size.width, height:20))
            titleLbl.text="POPULAR"
            titleLbl.textAlignment = .center
            titleLbl.font=UIFont.systemFont(ofSize:15)
            titleLbl.textColor = .darkGray
            
            headerView.addSubview(titleLbl)
            
            return headerView
        }
    }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath)->CGFloat
    {
        if indexPath.section==0
        {
            return canExpand ? 235 : 410
        }
        else if indexPath.section==1
        {
            return 202
        }
        else
        {
            return 180
        }
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath)->UITableViewCell
    {
        if indexPath.section==0
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"AboutVideoCell") as! AboutVideoCell
            
            cell.channelButton.addTarget(self, action:#selector(goToChannel), for:.touchUpInside)
            cell.shareButton.addTarget(self, action:#selector(share), for:.touchUpInside)
            
            if canExpand
            {
                cell.expandButton.setTitle("Read more", for:.normal)
                if layer==nil
                {
                    layer=CAGradientLayer()
                    layer.frame=cell.infoView.bounds
                    layer.colors=[UIColor(red:19/255, green:19/255, blue:19/255, alpha:1).cgColor]
                    cell.infoView.layer.insertSublayer(layer, at:0)
                }
            }
            else
            {
                cell.expandButton.setTitle("Pick up", for:.normal)
                if layer != nil
                {
                    layer.removeFromSuperlayer()
                    layer=nil
                }
            }
            
            if let obj=homeClassReference
            {
                cell.delegate=obj
            }
            if let obj=categoryClassReference
            {
                cell.delegate=obj
            }
            if let obj=channelClassReference
            {
                cell.delegate=obj
            }
            
            cell.update(stream)
            
            return cell
        }
        else if indexPath.section==1
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"cell") as! RelatedVideoCell
            
            cell.relatedVideosArray=relatedVideosArray
            cell.stream=stream
            cell.delegate=self
            cell.reloadCollectionView()
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"RelatedVideoCell") as! RecentlyPlayedCell
            
            let stream=popularVideosArray[indexPath.row] as! Stream
            
            cell.durationLbl.layer.borderColor=UIColor.white.cgColor
            cell.durationLbl.text=stream.duration
            cell.videoTitleLbl.text=stream.title.uppercased()
            cell.videoTitleLbl.addCharacterSpacing()
            cell.artistNameLbl.text=stream.category.uppercased()
            cell.artistNameLbl.addCharacterSpacing()
            cell.videoThumbnailImageView.sd_setImage(with:URL(string:"\(stream.imgUrl)"), placeholderImage:UIImage(named:"stream"))
            
            return cell
        }
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath)
    {
        if indexPath.section==2
        {
            NotificationCenter.default.removeObserver(self, name:.MPMoviePlayerPlaybackDidFinish, object:player)
            stream=popularVideosArray[indexPath.row] as! Stream
            relatedVideosTbl.reloadRows(at:[IndexPath(row:0, section:0)], with:.none)
            addPlayer()
        }
    }
    
    func tableView(_ tableView:UITableView, willDisplay cell:UITableViewCell, forRowAt indexPath:IndexPath)
    {
        if indexPath.section==1
        {
            let cell=cell as! RelatedVideoCell
            
            cell.reloadCollectionView()
        }
    }
    
    func share()
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"PopUpViewController") as! PopUpViewController
        vc.stream=stream
        present(vc, animated:true)
    }
    
    @IBAction func readMore()
    {
        if canExpand
        {
            canExpand=false
            relatedVideosTbl.reloadRows(at:[IndexPath(row:0, section:0)], with:.none)
        }
        else
        {
            canExpand=true
            relatedVideosTbl.reloadRows(at:[IndexPath(row:0, section:0)], with:.none)
        }
    }
    
    @IBAction func play()
    {
        if isPlaying
        {
            player.pause()
            
            playButton.setImage(UIImage(named:"big_play_button"), for:.normal)
            isPlaying=false
        }
        else
        {
            player.play()
            
            playButton.setImage(UIImage(named:"big_pause_button"), for:.normal)
            isPlaying=true
        }
    }
    
    @IBAction func previous()
    {
        NotificationCenter.default.removeObserver(self, name:.MPMoviePlayerPlaybackDidFinish, object:player)
        selectedItemIndex=selectedItemIndex-1
        stream=relatedVideosArray[selectedItemIndex] as! Stream
        relatedVideosTbl.reloadRows(at:[IndexPath(row:0, section:0), IndexPath(row:0, section:1)], with:.none)
        addPlayer()
    }
    
    @IBAction func next()
    {
        NotificationCenter.default.removeObserver(self, name:.MPMoviePlayerPlaybackDidFinish, object:player)
        selectedItemIndex=selectedItemIndex+1
        stream=relatedVideosArray[selectedItemIndex] as! Stream
        relatedVideosTbl.reloadRows(at:[IndexPath(row:0, section:0), IndexPath(row:0, section:1)], with:.none)
        addPlayer()
    }
    
    func goToChannel()
    {
        view.window?.rootViewController?.dismiss(animated:true, completion:nil)
        NotificationCenter.default.post(name: Notification.Name("goToChannels"), object:stream.user)
    }
    
    func relatedVideoDidSelected(_ index:Int)
    {
        NotificationCenter.default.removeObserver(self, name:.MPMoviePlayerPlaybackDidFinish, object:player)
        selectedItemIndex=index
        stream=relatedVideosArray[index] as! Stream
        relatedVideosTbl.reloadRows(at:[IndexPath(row:0, section:0), IndexPath(row:0, section:1)], with:.none)
        addPlayer()
    }
    
    func updateRelatedVideosArray(_ videos:NSMutableArray)
    {
        relatedVideosArray=videos
        updateButtons()
    }
    
    func addPlayer()
    {
        updateButtons()
        
        seekBar.value=0
        videoProgressDurationLbl.text="0:00"
        videoDurationLbl.text="-0:00"
        
        if player != nil
        {
            player.view.removeFromSuperview()
        }
        
        player=DWMoviePlayerController(userId:"D43560320694466A", key:"WGbPBVI3075vGwA0AIW0SR9pDTsQR229")
        player.controlStyle = .none
        player.scalingMode = .aspectFit
        
        if SongManager.isAlreadyDownloaded(stream.id)
        {
            player.contentURL=URL(fileURLWithPath:"\(SongManager.documentsDir)/\(stream.videoID).mp4")
        }
        else
        {
            player.videoId=stream.videoID
            player.startRequestPlayInfo()
        }
        
        player.play()
        
        let orientation=UIApplication.shared.statusBarOrientation
        
        if UIInterfaceOrientationIsLandscape(orientation)
        {
            player.view.frame=CGRect(x:0, y:0, width:view.frame.size.width, height:view.frame.size.height)
        }
        else
        {
            player.view.frame=CGRect(x:0, y:0, width:view.frame.size.width, height:playerHeightConstraint.constant)
        }
        
        view.addSubview(player.view)
        view.sendSubview(toBack:player.view)
        
        NotificationCenter.default.addObserver(self, selector:#selector(moviePlayerDurationAvailable), name:.MPMovieDurationAvailable, object:player)
        NotificationCenter.default.addObserver(self, selector:#selector(movieFinish), name:.MPMoviePlayerPlaybackDidFinish, object:player)
        
        Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(timerHandler), userInfo:nil, repeats:true)
    }
    
    func movieFinish()
    {
        next()
    }
    
    func moviePlayerDurationAvailable()
    {
        videoDurationLbl.text="-\(secondsToReadableTime(player.duration))"
        seekBar.maximumValue=Float(player.duration)
    }
    
    func timerHandler()
    {
        videoDurationLbl.text="-\(secondsToReadableTime(player.duration-player.currentPlaybackTime))"
        videoProgressDurationLbl.text=secondsToReadableTime(player.currentPlaybackTime)
        seekBar.value=Float(player.currentPlaybackTime)
        
        TBVC.updateSeekBar()
    }
    
    @IBAction func seekBarValueChanged()
    {
        player.seekStartTime=player.currentPlaybackTime
        player.currentPlaybackTime=Double(seekBar.value)
        
        videoProgressDurationLbl.text=secondsToReadableTime(player.currentPlaybackTime)
        videoDurationLbl.text="-\(secondsToReadableTime(player.duration-player.currentPlaybackTime))"
    }
    
    @IBAction func rotateScreen()
    {
        let orientation=UIApplication.shared.statusBarOrientation
        
        if UIInterfaceOrientationIsLandscape(orientation)
        {
            let value=UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey:"orientation")
        }
        else
        {
            let value=UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey:"orientation")
        }
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
        player.view.frame=CGRect(x:0, y:0, width:view.frame.size.width, height:view.frame.size.height)
        playerHeightConstraint.constant=view.frame.size.height
        fullScreenButton.setImage(UIImage(named:"nonfullscreen"), for:.normal)
        
        for gesture in view.gestureRecognizers!
        {
            gesture.isEnabled=false
        }
    }
    
    func showPortrait()
    {
        let screenSize=UIScreen.main.bounds.height
        
        if screenSize==568
        {
            playerHeightConstraint.constant=227
        }
        else if screenSize==667
        {
            playerHeightConstraint.constant=267
        }
        else if screenSize==736
        {
            playerHeightConstraint.constant=294
        }
        else
        {
            playerHeightConstraint.constant=325
        }
        
        player.view.frame=CGRect(x:0, y:0, width:view.frame.size.width, height:playerHeightConstraint.constant)
        
        fullScreenButton.setImage(UIImage(named:"fullscreen"), for:.normal)
        
        for gesture in view.gestureRecognizers!
        {
            gesture.isEnabled=true
        }
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
        nextButton.isEnabled=true
        previousButton.isEnabled=true
        
        if selectedItemIndex==0
        {
            previousButton.isEnabled=false
        }
        
        if selectedItemIndex==relatedVideosArray.count-1||relatedVideosArray.count==0
        {
            nextButton.isEnabled=false
        }
    }
    
    func relatedVideosSuccess(data:NSDictionary)
    {
        relatedVideosArray.addObjects(from:getData(data) as [AnyObject])
        updateButtons()
    }
    
    func popularVideosSuccess(_ data:NSDictionary)
    {
        popularVideosArray.addObjects(from:getData(data) as [AnyObject])
        relatedVideosTbl.reloadData()
    }
    
    func fetchMorePopularVideosSuccess(data:NSDictionary)
    {
        relatedVideosTbl.infiniteScrollingView.stopAnimating()
        popularVideosSuccess(data)
    }
    
    func getData(_ data:NSDictionary)->NSMutableArray
    {
        let videos=data["data"] as! NSArray
        
        let videosArray=NSMutableArray()
        
        for i in 0 ..< videos.count
        {
            let video=videos[i] as! NSDictionary
            
            let user=video["user"] as! NSDictionary
            
            let oneUser=User()
            oneUser.id=user["id"] as! Int
            oneUser.name=user["name"] as! String
            oneUser.avatar=user["avatar"] as? String
            
            let oneVideo=Stream()
            oneVideo.id=video["id"] as! Int
            oneVideo.vType=video["vtype"] as! Int
            oneVideo.videoID=video["streamkey"] as! String
            oneVideo.title=video["title"] as! String
            oneVideo.streamHash=video["hash"] as! String
            oneVideo.lon=video["lon"] as! Double
            oneVideo.lat=video["lat"] as! Double
            oneVideo.city=video["city"] as! String
            oneVideo.brand=video["brand"] as! String
            oneVideo.venue=video["venue"] as! String
            oneVideo.imgUrl=video["imgUrl"] as! String
            oneVideo.duration=video["duration"] as! String
            oneVideo.cid=video["cid"] as! Int
            oneVideo.category=video["category"] as! String
            oneVideo.PRAgency=video["pr_agency"] as! String
            oneVideo.musicAgency=video["music_agency"] as! String
            oneVideo.adAgency=video["ad_agency"] as! String
            oneVideo.talentAgency=video["talent_agency"] as! String
            oneVideo.eventAgency=video["event_agency"] as! String
            oneVideo.videoAgency=video["video_agency"] as! String
            oneVideo.year=video["year"] as! String
            oneVideo.videoDescription=video["description"] as! String
            
            if let e=video["ended"] as? String
            {
                oneVideo.ended=NSDate(timeIntervalSince1970:Double(e)!)
            }
            
            oneVideo.viewers=video["viewers"] as! Int
            oneVideo.tviewers=video["tviewers"] as! Int
            oneVideo.rviewers=video["rviewers"] as! Int
            oneVideo.likes=video["likes"] as! Int
            oneVideo.shares=video["sharecount"] as! Int
            oneVideo.comments=video["commentcount"] as! Int
            oneVideo.rlikes=video["rlikes"] as! Int
            oneVideo.user=oneUser
            
            videosArray.add(oneVideo)
        }
        
        return videosArray
    }
    
    func failureStream(error:NSError)
    {
        handleError(error)
    }
}
