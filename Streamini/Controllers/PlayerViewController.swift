//
//  PlayerViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 1/4/18.
//  Copyright © 2018 Cedricm Video. All rights reserved.
//

class PlayerViewController: UIViewController
{
    @IBOutlet var videoProgressDurationLbl:UILabel!
    @IBOutlet var videoDurationLbl:UILabel!
    @IBOutlet var seekBar:UISlider!
    @IBOutlet var playButton:UIButton!
    @IBOutlet var relatedVideosTbl:UITableView!
    
    var isPlaying=true
    var TBVC:TabBarViewController!
    var player:DWMoviePlayerController!
    var stream:Stream!
    var timer:Timer!
    
    override func viewDidLoad()
    {
        addPlayer()
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 1
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"AboutVideoCell") as! AboutVideoCell
        
        cell.update(stream)
        
        return cell
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
    
    func addPlayer()
    {
        seekBar.value=0
        videoProgressDurationLbl.text="0:00"
        videoDurationLbl.text="-0:00"
        
        player=DWMoviePlayerController(userId:"D43560320694466A", key:"WGbPBVI3075vGwA0AIW0SR9pDTsQR229")
        player.controlStyle = .none
        player.scalingMode = .aspectFit
        
        player.videoId=stream.videoID
        player.startRequestPlayInfo()
        player.play()
        
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
}
