//
//  ChannelsViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 7/28/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class ChannelsViewController: UIViewController
{
    @IBOutlet var itemsTbl:UITableView!
    
    var allChannelsVideosArray=NSMutableArray()
    
    override func viewDidLoad()
    {
        
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 10
    }
    
    func tableView(_ tableView:UITableView, heightForRowAtIndexPath indexPath:IndexPath)->CGFloat
    {
        return 292
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"ChannelCell") as! ChannelCell
        
        return cell
    }
    
    func tableView(_ tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:IndexPath)
    {
        let cell=cell as! ChannelCell
        
        cell.reloadCollectionView()
    }
    
    func successStreams(data:NSDictionary)
    {
        let categories=data["data"] as! NSArray
        
        for i in 0 ..< categories.count
        {
            let category=categories[i] as! NSDictionary
            
            let videos=category["videos"] as! NSArray
            
            let channelVideosArray=NSMutableArray()
            
            for j in 0 ..< videos.count
            {
                let video=videos[j] as! NSDictionary
                
                let videoID=video["id"] as! Int
                let streamKey=video["streamkey"] as! String
                let vType=video["vtype"] as! Int
                let videoTitle=video["title"] as! String
                let videoHash=video["hash"] as! String
                let lon=video["lon"] as! Double
                let lat=video["lat"] as! Double
                let city=video["city"] as! String
                let ended=video["ended"] as? String
                let viewers=video["viewers"] as! Int
                let tviewers=video["tviewers"] as! Int
                let rviewers=video["rviewers"] as! Int
                let likes=video["likes"] as! Int
                let rlikes=video["rlikes"] as! Int
                
                let user=video["user"] as! NSDictionary
                
                let userID=user["id"] as! Int
                let userName=user["name"] as! String
                let userAvatar=user["avatar"] as? String
                
                let oneUser=User()
                
                oneUser.id=UInt(userID)
                oneUser.name=userName
                oneUser.avatar=userAvatar
                
                let oneVideo=Stream()
                oneVideo.id=UInt(videoID)
                oneVideo.vType=vType
                oneVideo.videoID=streamKey
                oneVideo.title=videoTitle
                oneVideo.streamHash=videoHash
                oneVideo.lon=lon
                oneVideo.lat=lat
                oneVideo.city=city
                
                if let e=ended
                {
                    oneVideo.ended=NSDate(timeIntervalSince1970:Double(e)!)
                }
                
                oneVideo.viewers=UInt(viewers)
                oneVideo.tviewers=UInt(tviewers)
                oneVideo.rviewers=UInt(rviewers)
                oneVideo.likes=UInt(likes)
                oneVideo.rlikes=UInt(rlikes)
                oneVideo.user=oneUser
                
                channelVideosArray.add(oneVideo)
            }
            
            allChannelsVideosArray.add(channelVideosArray)
        }
        
        itemsTbl!.reloadData()
        itemsTbl!.isHidden=false
    }
    
    func failureStream(error:NSError)
    {
        
    }
}
