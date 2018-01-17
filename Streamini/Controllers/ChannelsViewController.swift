//
//  ChannelsViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 7/28/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class ChannelsViewController: BaseViewController
{
    @IBOutlet var itemsTbl:UITableView!
    
    var channelUsersVideosArray=NSMutableArray()
    var channelName:String!
    var channelID:Int!
    var page=0
    
    override func viewDidLoad()
    {
        navigationItem.title=channelName
        
        itemsTbl.addInfiniteScrolling{()->() in
            self.fetchMore()
        }
        
        StreamConnector().channelStreams(channelID, page, successStreams, failureStream)
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        navigationController?.isNavigationBarHidden=false
    }
    
    func fetchMore()
    {
        page+=1
        StreamConnector().channelStreams(channelID, page, fetchMoreSuccess, failureStream)
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return channelUsersVideosArray.count
    }
        
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"ChannelCell") as! ChannelCell
        
        let userVideosArray=channelUsersVideosArray[indexPath.row] as! NSArray
        let user=(userVideosArray[0] as! Stream).user
        
        cell.update(user)
        cell.TBVC=tabBarController as! TabBarViewController
        cell.userVideosArray=userVideosArray
        
        return cell
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAtIndexPath indexPath:IndexPath)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"UserViewControllerId") as! UserViewController
        let userVideosArray=channelUsersVideosArray[indexPath.row] as! NSArray
        vc.user=(userVideosArray[0] as! Stream).user
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func tableView(_ tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:IndexPath)
    {
        let cell=cell as! ChannelCell
        
        cell.reloadCollectionView()
    }
    
    func successStreams(data:NSDictionary)
    {
        parseData(data)
    }
    
    func fetchMoreSuccess(data:NSDictionary)
    {
        itemsTbl?.infiniteScrollingView.stopAnimating()
        parseData(data)
    }
    
    func parseData(_ data:NSDictionary)
    {
        let users=data["data"] as! NSArray
        
        for i in 0 ..< users.count
        {
            let user=users[i] as! NSDictionary
            
            let videos=user["videos"] as! NSArray
            
            let userVideosArray=NSMutableArray()
            
            for j in 0 ..< videos.count
            {
                let video=videos[j] as! NSDictionary
                
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
                
                userVideosArray.add(oneVideo)
            }
            
            channelUsersVideosArray.add(userVideosArray)
        }
        
        itemsTbl?.reloadData()
    }
    
    func failureStream(error:NSError)
    {
        handleError(error)
    }
}
