//
//  CategoriesViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/9/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class CategoriesViewController: BaseViewController, PlayerViewControllerDelegate
{
    @IBOutlet var itemsTbl:UITableView!
    @IBOutlet var headerLbl:UILabel!
    @IBOutlet var topImageView:UIImageView!
    @IBOutlet var headerView:GSKStretchyHeaderView!
    @IBOutlet var backButtonImageView:UIImageView!
    @IBOutlet var backButton:UIButton!
    
    var allItemsArray=NSMutableArray()
    var categoryName:String!
    var page=0
    var isSubCategory=false
    var categoryID:Int!
    var TBVC:TabBarViewController!
    let site=Config.shared.site()
    
    override func viewDidLoad()
    {
        headerLbl.frame=CGRect(x:(view.frame.size.width-200)/2, y:32, width:200, height:20)
        
        if view.frame.size.height>667
        {
            headerView.minimumContentHeight=88
            backButtonImageView.frame=CGRect(x:15, y:54, width:13, height:24)
            backButton.frame=CGRect(x:0, y:0, width:100, height:88)
            headerLbl.frame=CGRect(x:(view.frame.size.width-200)/2, y:56, width:200, height:20)
        }
        
        TBVC=tabBarController as! TabBarViewController
        
        headerLbl.text=categoryName.uppercased()
        navigationController?.isNavigationBarHidden=true
        itemsTbl.addInfiniteScrolling{()->() in
            self.fetchMore()
        }
        
        StreamConnector().categoryStreams(isSubCategory, false, categoryID, page, successStreams, failureStream)
        
        if isSubCategory
        {
            topImageView.sd_setImage(with:URL(string:"\(site)/media/sub-categories/\(categoryID!).jpg"))
        }
        else
        {
            topImageView.sd_setImage(with:URL(string:"\(site)/media/categories/\(categoryID!).jpg"))
        }
        
        itemsTbl.addSubview(headerView)
    }
    
    func scrollViewDidScroll(_ scrollView:UIScrollView)
    {
        var range:CGFloat=136
        var openAmount=headerView.frame.size.height-64
        
        if view.frame.size.height>667
        {
            range=112
            openAmount=headerView.frame.size.height-88
        }
        
        let percentage=openAmount/range
        topImageView.alpha=percentage
    }
    
    func fetchMore()
    {
        page+=1
        StreamConnector().categoryStreams(isSubCategory, false, categoryID, page, fetchMoreSuccess, failureStream)
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return allItemsArray.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"cell") as! RecentlyPlayedCell
        
        let video=allItemsArray[indexPath.row] as! Stream
        
        cell.videoTitleLbl.text=video.title
        cell.artistNameLbl.text=video.user.name
        cell.userImageView.sd_setImage(with:URL(string:"\(site)/uploads/\(video.user.id)-avatar.jpg"), placeholderImage:UIImage(named:"profile"))
        cell.videoThumbnailImageView.sd_setImage(with:URL(string:"\(site)/thumb/\(video.id).jpg"), placeholderImage:UIImage(named:"videostream"))
        
        let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
        cell.tag=indexPath.row
        cell.addGestureRecognizer(cellRecognizer)
        
        return cell
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let playerVC=storyboard.instantiateViewController(withIdentifier:"PlayerViewController") as! PlayerViewController
        
        let stream=allItemsArray[gestureRecognizer.view!.tag] as! Stream
        
        playerVC.stream=stream
        playerVC.TBVC=TBVC
        playerVC.categoryClassReference=self
        
        TBVC.playerVC=playerVC
        TBVC.configure(stream)
    }
    
    @IBAction func back()
    {
        navigationController!.popViewController(animated:true)
    }
    
    func successStreams(data:NSDictionary)
    {
        allItemsArray.addObjects(from:getData(data) as [AnyObject])
        itemsTbl.reloadData()
    }
    
    func fetchMoreSuccess(data:NSDictionary)
    {
        itemsTbl.infiniteScrollingView.stopAnimating()
        allItemsArray.addObjects(from:getData(data) as [AnyObject])
        itemsTbl.reloadData()
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
            oneUser.isFollowed=user["isfollowed"] as! Bool
            
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
    
    func updateSubscribeStatus(_ stream:Stream, _ isFollowed:Bool)
    {
        let userID=stream.user.id
        
        for i in 0 ..< allItemsArray.count
        {
            let s=allItemsArray[i] as! Stream
            
            if s.user.id==userID
            {
                allItemsArray.remove(s)
                s.user.isFollowed=isFollowed
                allItemsArray.insert(s, at:i)
            }
        }
    }
}
