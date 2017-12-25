//
//  CategoriesViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/9/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class CategoriesViewController: BaseViewController
{
    @IBOutlet var itemsTbl:UITableView?
    @IBOutlet var headerLbl:UILabel?
    @IBOutlet var topImageView:UIImageView?
    @IBOutlet var shufflePlayButton:UIButton!
    @IBOutlet var headerView:GSKStretchyHeaderView!
    
    var allItemsArray=NSMutableArray()
    var categoryName:String?
    var page=0
    var categoryID:Int?
    var TBVC:TabBarViewController!
    let site=Config.shared.site()
    
    override func viewDidLoad()
    {
        TBVC=tabBarController as! TabBarViewController
        
        headerLbl?.text=categoryName?.uppercased()
        navigationController?.isNavigationBarHidden=true
        itemsTbl?.addInfiniteScrolling{()->() in
            self.fetchMore()
        }
        
        StreamConnector().categoryStreams(categoryID!, page, successStreams, failureStream)
        
        topImageView?.sd_setImage(with:URL(string:"\(site)/media/sub-categories/\(categoryID!).jpg"))
        
        itemsTbl?.addSubview(headerView)
    }
    
    func scrollViewDidScroll(_ scrollView:UIScrollView)
    {
        let range:CGFloat=116
        let openAmount=headerView.frame.size.height-104
        let percentage=openAmount/range
        
        topImageView?.alpha=percentage
    }
    
    func fetchMore()
    {
        page+=1
        StreamConnector().categoryStreams(categoryID!, page, fetchMoreSuccess, failureStream)
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return allItemsArray.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"cell") as! RecentlyPlayedCell
        
        let video=allItemsArray[indexPath.row] as! Stream
        
        cell.videoTitleLbl?.text=video.title
        cell.artistNameLbl?.text=video.user.name
        cell.userImageView?.sd_setImage(with:URL(string:"\(site)/uploads/\(video.user.id)-avatar.jpg"), placeholderImage:UIImage(named:"profile"))
        cell.videoThumbnailImageView?.sd_setImage(with:URL(string:"\(site)/thumb/\(video.id).jpg"), placeholderImage:UIImage(named:"videostream"))
        
        let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
        cell.tag=indexPath.row
        cell.addGestureRecognizer(cellRecognizer)
        
        return cell
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let modalVC=storyboard.instantiateViewController(withIdentifier:"ModalViewController") as! ModalViewController
        
        let stream=allItemsArray[gestureRecognizer.view!.tag] as! Stream
        
        let streamsArray=NSMutableArray()
        streamsArray.add(stream)
        
        modalVC.streamsArray=streamsArray
        modalVC.TBVC=TBVC
        
        TBVC.modalVC=modalVC
        TBVC.configure(stream)
    }
    
    @IBAction func back()
    {
        navigationController!.popViewController(animated:true)
    }
    
    func successStreams(data:NSDictionary)
    {
        shufflePlayButton.isEnabled=true
        allItemsArray.addObjects(from:getData(data) as [AnyObject])
        itemsTbl?.reloadData()
    }
    
    func fetchMoreSuccess(data:NSDictionary)
    {
        itemsTbl?.infiniteScrollingView.stopAnimating()
        allItemsArray.addObjects(from:getData(data) as [AnyObject])
        itemsTbl?.reloadData()
    }
    
    func getData(_ data:NSDictionary)->NSMutableArray
    {
        let videos=data["data"] as! NSArray
        
        let allItemsArray=NSMutableArray()
        
        for i in 0 ..< videos.count
        {
            let video=videos[i] as! NSDictionary
            
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
            
            allItemsArray.add(oneVideo)
        }
        
        return allItemsArray
    }
    
    func failureStream(error:NSError)
    {
        handleError(error)
    }
    
    @IBAction func shufflePlay()
    {
        let modalVC=storyBoard.instantiateViewController(withIdentifier:"ModalViewController") as! ModalViewController
        
        let random=Int(arc4random_uniform(UInt32(allItemsArray.count)))
        let stream=allItemsArray[random] as! Stream
        
        modalVC.selectedItemIndex=random
        modalVC.streamsArray=allItemsArray
        modalVC.TBVC=TBVC
        
        TBVC.modalVC=modalVC
        TBVC.configure(stream)
    }
}
