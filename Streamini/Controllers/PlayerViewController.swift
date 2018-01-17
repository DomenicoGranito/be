//
//  PlayerViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 1/4/18.
//  Copyright © 2018 Cedricm Video. All rights reserved.
//

class PlayerViewController: BaseViewController
{
    @IBOutlet var videoProgressDurationLbl:UILabel!
    @IBOutlet var videoDurationLbl:UILabel!
    @IBOutlet var seekBar:UISlider!
    @IBOutlet var playButton:UIButton!
    @IBOutlet var previousButton:UIButton!
    @IBOutlet var nextButton:UIButton!
    @IBOutlet var relatedVideosTbl:UITableView!
    
    let site=Config.shared.site()
    var allItemsArray=NSMutableArray()
    var isPlaying=true
    var TBVC:TabBarViewController!
    var player:DWMoviePlayerController!
    var stream:Stream!
    var originalStream:Stream!
    var timer:Timer!
    var page=0
    var selectedItemIndex=0
    
    override func viewDidLoad()
    {
        originalStream=stream
        
        relatedVideosTbl.addInfiniteScrolling{()->() in
            self.fetchMore()
        }
        
        StreamConnector().categoryStreams(false, true, stream.cid, page, successStreams, failureStream)
        
        addPlayer()
    }
    
    override func viewDidAppear(_ animated:Bool)
    {
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
    }
    
    func fetchMore()
    {
        //page+=1
        //StreamConnector().categoryStreams(false, true, stream.cid, page, fetchMoreSuccess, failureStream)
    }
    
    func tableView(_ tableView:UITableView, heightForRowAtIndexPath indexPath:IndexPath)->CGFloat
    {
        return indexPath.row==0 ? 320 : 80
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return allItemsArray.count+1
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        if indexPath.row==0
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"AboutVideoCell") as! AboutVideoCell
            
            cell.update(stream)
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"RelatedVideoCell") as! RecentlyPlayedCell
            
            let stream=allItemsArray[indexPath.row-1] as! Stream
            
            cell.videoTitleLbl.text=stream.title
            cell.artistNameLbl.text=stream.user.name
            cell.videoThumbnailImageView.sd_setImage(with:URL(string:"\(site)/thumb/\(stream.id).jpg"), placeholderImage:UIImage(named:"stream"))
            
            return cell
        }
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAtIndexPath indexPath:IndexPath)
    {
        if indexPath.row>0
        {
            selectedItemIndex=indexPath.row-1
            stream=allItemsArray[selectedItemIndex] as! Stream
            relatedVideosTbl.reloadRows(at:[IndexPath(row:0, section:0)], with:.fade)
            updateButtons()
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
        selectedItemIndex=selectedItemIndex-1
        stream=selectedItemIndex==0 ? originalStream : allItemsArray[selectedItemIndex] as! Stream
        relatedVideosTbl.reloadRows(at:[IndexPath(row:0, section:0)], with:.fade)
        updateButtons()
    }
    
    @IBAction func next()
    {
        selectedItemIndex=selectedItemIndex+1
        stream=allItemsArray[selectedItemIndex-1] as! Stream
        relatedVideosTbl.reloadRows(at:[IndexPath(row:0, section:0)], with:.fade)
        updateButtons()
    }
    
    func addPlayer()
    {
        seekBar.value=0
        videoProgressDurationLbl.text="0:00"
        videoDurationLbl.text="-0:00"
        
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
        
        player.view.removeFromSuperview()
        player.view.frame=CGRect(x:0, y:0, width:view.frame.size.width, height:160)
        view.addSubview(player.view)
        view.sendSubview(toBack:player.view)
        
        NotificationCenter.default.addObserver(self, selector:#selector(moviePlayerDurationAvailable), name:.MPMovieDurationAvailable, object:player)
        
        timer=Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(timerHandler), userInfo:nil, repeats:true)
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
        
        if selectedItemIndex==allItemsArray.count-1
        {
            nextButton.isEnabled=false
        }
    }
    
    func successStreams(data:NSDictionary)
    {
        allItemsArray.addObjects(from:getData(data) as [AnyObject])
        relatedVideosTbl.reloadData()
        updateButtons()
    }
    
    func fetchMoreSuccess(data:NSDictionary)
    {
        relatedVideosTbl.infiniteScrollingView.stopAnimating()
        allItemsArray.addObjects(from:getData(data) as [AnyObject])
        relatedVideosTbl.reloadData()
    }
    
    func getData(_ data:NSDictionary)->NSMutableArray
    {
        let videos=data["data"] as! NSArray
        
        let allItemsArray=NSMutableArray()
        
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
            
            allItemsArray.add(oneVideo)
        }
        
        return allItemsArray
    }
    
    func failureStream(error:NSError)
    {
        handleError(error)
    }
}
