//
//  HomeViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/8/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class HomeViewController: BaseViewController, PlayerViewControllerDelegate
{
    @IBOutlet var itemsTbl:UITableView!
    @IBOutlet var errorView:ErrorView!
    @IBOutlet var activityView:ActivityIndicatorView!
    
    var categoryNamesArray=NSMutableArray()
    var categoryIDsArray=NSMutableArray()
    var allCategoryItemsArray=NSMutableArray()
    var timer:Timer?
    let site=Config.shared.site()
    
    override func viewDidLoad()
    {
        NotificationCenter.default.addObserver(self, selector:#selector(updateUI), name:Notification.Name("refreshAfterBlock"), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(updateUI), name:Notification.Name("status"), object:nil)
        
        updateUI()
    }
    
    func updateSubscribeStatus(_ stream:Stream, _ isFollowed:Bool)
    {
        let userID=stream.user.id
        
        for i in 0 ..< allCategoryItemsArray.count
        {
            let streamsArray=allCategoryItemsArray[i] as! NSMutableArray
            allCategoryItemsArray.remove(streamsArray)
            
            for j in 0 ..< streamsArray.count
            {
                let s=streamsArray[j] as! Stream
                
                if s.user.id==userID
                {
                    streamsArray.remove(s)
                    s.user.isFollowed=isFollowed
                    streamsArray.insert(s, at:j)
                }
            }
            
            allCategoryItemsArray.insert(streamsArray, at:i)
        }
    }
    
    func updateUI()
    {
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.reachability.isReachable
        {
            errorView.isHidden=true
            activityView.isHidden=false
            
            view.bringSubview(toFront:activityView)
            StreamConnector().homeStreams(successStreams, failureStream)
        }
        else
        {
            itemsTbl.isHidden=true
            activityView.isHidden=true
            errorView.update("No Internet Connection", "user")
        }
    }
    
    func reload()
    {
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.reachability.isReachable
        {
            errorView.isHidden=true
            
            StreamConnector().homeStreams(successStreams, failureStream)
        }
        else
        {
            itemsTbl.isHidden=true
            errorView.update("No Internet Connection", "user")
        }
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        navigationController?.isNavigationBarHidden=true
        
        timer=Timer.scheduledTimer(timeInterval:15, target:self, selector:#selector(reload), userInfo:nil, repeats:true)
    }
    
    override func viewWillDisappear(_ animated:Bool)
    {
        //timer!.invalidate()
    }
    
    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return section==0 ? view.frame.size.height+190 : 190
    }
    
    func tableView(_ tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        var headerHeight:CGFloat=0
        
        let headerView=UIView(frame:CGRect(x:0, y:0, width:view.frame.size.width, height:190))
        headerView.backgroundColor=UIColor(red:18/255, green:19/255, blue:21/255, alpha:1)
        
        if section==0
        {
            headerHeight=view.frame.size.height
            headerView.frame=CGRect(x:0, y:0, width:view.frame.size.width, height:view.frame.size.height+190)
            
            let player=AVPlayer(url:URL(string:"https://api.cedricm.com/media/featured/banner.mp4")!)
            player.isMuted=true
            let playerLayer=AVPlayerLayer(player:player)
            playerLayer.frame=CGRect(x:0, y:0, width:view.frame.size.width, height:view.frame.size.height)
            playerLayer.videoGravity=AVLayerVideoGravityResize
            headerView.layer.addSublayer(playerLayer)
            player.play()
        }
        
        let seriesLbl=UILabel(frame:CGRect(x:10, y:headerHeight+10, width:view.frame.size.width-20, height:20))
        seriesLbl.text="SERIES"
        seriesLbl.font=UIFont.systemFont(ofSize:13)
        seriesLbl.textColor = .white
        seriesLbl.textAlignment = .center
        
        let titleLbl=UILabel(frame:CGRect(x:10, y:headerHeight+40, width:view.frame.size.width-20, height:30))
        
        if(allCategoryItemsArray.count>0)
        {
            titleLbl.text=(categoryNamesArray[section] as AnyObject).uppercased
        }
        
        titleLbl.font=UIFont.systemFont(ofSize:20)
        titleLbl.textColor = .white
        titleLbl.textAlignment = .center
        
        let descriptionLbl=UILabel(frame:CGRect(x:10, y:headerHeight+80, width:view.frame.size.width-20, height:50))
        descriptionLbl.text="BE IN IT. Original Series Studio(s) explores the creative process through those who define modern culture."
        descriptionLbl.numberOfLines=3
        descriptionLbl.font=UIFont.systemFont(ofSize:13)
        descriptionLbl.textColor = .white
        descriptionLbl.textAlignment = .center
        
        let seeAllButton=UIButton(frame:CGRect(x:(view.frame.size.width-80)/2, y:headerHeight+140, width:80, height:40))
        seeAllButton.setTitle("SEE ALL", for:.normal)
        seeAllButton.titleLabel?.font=UIFont.systemFont(ofSize:13)
        seeAllButton.layer.borderWidth=1
        seeAllButton.layer.borderColor=UIColor.gray.cgColor
        
        let tapGesture=UITapGestureRecognizer(target:self, action:#selector(headerTapped))
        headerView.addGestureRecognizer(tapGesture)
        headerView.tag=section
        
        headerView.addSubview(seriesLbl)
        headerView.addSubview(titleLbl)
        headerView.addSubview(descriptionLbl)
        headerView.addSubview(seeAllButton)
        
        return headerView
    }
    
    func headerTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"CategoriesViewController") as! CategoriesViewController
        vc.categoryName=categoryNamesArray[gestureRecognizer.view!.tag] as? String
        vc.categoryID=categoryIDsArray[gestureRecognizer.view!.tag] as? Int
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func numberOfSectionsInTableView(_ tableView:UITableView)->Int
    {
        return categoryNamesArray.count
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 1
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"cell") as! CategoryRow
        
        if(allCategoryItemsArray.count>0)
        {
            cell.TBVC=tabBarController as! TabBarViewController
            cell.oneCategoryItemsArray=allCategoryItemsArray[indexPath.section] as! NSArray
            cell.categoryName=categoryNamesArray[indexPath.section] as! String
            cell.categoryID=categoryIDsArray[indexPath.section] as! Int
            cell.navigationControllerReference=navigationController
            cell.homeClassReference=self
        }
        
        return cell
    }
    
    func tableView(_ tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:IndexPath)
    {
        let cell=cell as! CategoryRow
        
        cell.reloadCollectionView()
    }
    
    func successStreams(data:NSDictionary)
    {
        errorView.isHidden=true
        activityView.isHidden=true
        
        categoryNamesArray=NSMutableArray()
        categoryIDsArray=NSMutableArray()
        allCategoryItemsArray=NSMutableArray()
        
        let categories=data["data"] as! NSArray
        
        for i in 0 ..< categories.count
        {
            let category=categories[i] as! NSDictionary
            
            let categoryName=category["category_name"] as! String
            let categoryID=category["category_id"] as! Int
            
            categoryNamesArray.add(categoryName)
            categoryIDsArray.add(categoryID)
            
            let videos=category["videos"] as! NSArray
            
            let oneCategoryItemsArray=NSMutableArray()
            
            for j in 0 ..< videos.count
            {
                let video=videos[j] as! NSDictionary
                
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
                
                oneCategoryItemsArray.add(oneVideo)
            }
            
            allCategoryItemsArray.add(oneCategoryItemsArray)
        }
        
        itemsTbl.reloadData()
        itemsTbl.isHidden=false
    }
    
    func failureStream(error:NSError)
    {
        activityView.isHidden=true
        errorView.update("An error occured", "user")
    }
}
