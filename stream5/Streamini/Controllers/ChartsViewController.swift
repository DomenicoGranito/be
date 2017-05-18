////
////  CategoriesViewController.swift
////  Streamini
////
////  Created by Ankit Garg on 9/9/16.
////  Copyright © 2016 UniProgy s.r.o. All rights reserved.
////
//
//class ChartsViewController: BaseViewController
//{
//    @IBOutlet var itemsTbl:UITableView?
//    @IBOutlet var headerLbl:UILabel?
//    @IBOutlet var topImageView:UIImageView?
//    
//    var allItemsArray=NSMutableArray()
//    var categoryName:String?
//    var page=0
//    var categoryID:Int?
//    
//    override func viewDidLoad()
//    {
//        //headerLbl?.text=categoryName?.uppercased
//        navigationController?.isNavigationBarHidden=true
//        itemsTbl?.addInfiniteScrolling{()->Void in
//            self.fetchMore()
//        }
//        
//        StreamConnector().categoryStreams(7, pageID:page, success:successStreams, failure:failureStream)
//    }
//    
//    override func viewWillAppear(_ animated:Bool)
//    {
//        UIApplication.sharedApplication.setStatusBarHidden(false, withAnimation:.Fade)
//    }
//    
//    func fetchMore()
//    {
//        page+=1
//        StreamConnector().categoryStreams(7, pageID:page, success:fetchMoreSuccess, failure:failureStream)
//    }
//    
//    func tableView(_ tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
//    {
//        let headerView=UIView(frame:CGRectMake(0, 0, 60, tableView.frame.size.width))
//        headerView.backgroundColor=UIColor.clearColor
//        
//        let titleLbl=UILabel(frame:CGRectMake(10, 20, 150, 20))
//        titleLbl.text=categoryName?.uppercased
//        titleLbl.font=UIFont.systemFont(ofSize: 14)
//        titleLbl.textColor=UIColor.lightGrayColor
//        
//        let lineView=UIView(frame:CGRectMake(10, 59, tableView.frame.size.width-20, 1))
//        lineView.backgroundColor=UIColor.darkGrayColor
//        
//        headerView.addSubview(lineView)
//        headerView.addSubview(titleLbl)
//        
//        return headerView
//    }
//    
//    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
//    {
//        return allItemsArray.count
//    }
//    
//    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
//    {
//        //let cell=tableView.dequeueReusableCellWithIdentifier("cell") as! AllCategoriesRow
//        
//        //cell.sectionItemsArray=allItemsArray[indexPath.row] as! NSArray
//        //cell.navigationControllerReference=navigationController
//        
//        return UITableViewCell()
//    }
//    
//    func tableView(_ tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:NSIndexPath)
//    {
//        //let cell=cell as! AllCategoriesRow
//        
//        //cell.reloadCollectionView()
//    }
//    
//    @IBAction func back()
//    {
//        navigationController?.popViewController(animated: true)
//    }
//    
//    func successStreams(_ data:NSDictionary)
//    {
//        //allItemsArray.addObjects(from: getData(data) as [AnyObject])
//        itemsTbl?.reloadData()
//    }
//    
//    func fetchMoreSuccess(_ data:NSDictionary)
//    {
//        itemsTbl?.infiniteScrollingView.stopAnimating()
//        //allItemsArray.addObjects(from: getData(data) as [AnyObject])
//        itemsTbl?.reloadData()
//    }
//    
//    func getData(_ data:NSDictionary)->NSMutableArray
//    {
//        let data=data["data"]!
//        
//        var sectionItemsArray=NSMutableArray()
//        let allItemsArray=NSMutableArray()
//        var count=0
//        
//        for i in 0 ..< (data as AnyObject).count
//        {
//            let videoID=data[i]["id"] as! String
//            let videoTitle=data[i]["title"] as! String
//            let videoHash=data[i]["hash"] as! String
//            let lon=data[i]["lon"]!.doubleValue
//            let lat=data[i]["lat"]!.doubleValue
//            let city=data[i]["city"] as! String
//            let ended=data[i]["ended"] as? String
//            let viewers=data[i]["viewers"] as! String
//            let tviewers=data[i]["tviewers"] as! String
//            let rviewers=data[i]["rviewers"] as! String
//            let likes=data[i]["likes"] as! String
//            let rlikes=data[i]["rlikes"] as! String
//            let userID=data[i]["user"]!["id"] as! String
//            let userName=data[i]["user"]!["name"] as! String
//            let userAvatar=data[i]["user"]!["avatar"] as? String
//            
//            let user=User()
//            user.id=UInt(userID)!
//            user.name=userName
//            user.avatar=userAvatar
//            
//            let video=Stream()
//            video.id=UInt(videoID)!
//            video.title=videoTitle
//            video.streamHash=videoHash
//            video.lon=lon
//            video.lat=lat
//            video.city=city
//            
//            if let e=ended
//            {
//                video.ended=NSDate(timeIntervalSince1970:Double(e)!)
//            }
//            
//            video.viewers=UInt(viewers)!
//            video.tviewers=UInt(tviewers)!
//            video.rviewers=UInt(rviewers)!
//            video.likes=UInt(likes)!
//            video.rlikes=UInt(rlikes)!
//            video.user=user
//            
//            sectionItemsArray.addObject(video)
//            
//            count+=1
//            
//            if(count==2||(count==1&&i==data.count-1))
//            {
//                count=0
//                allItemsArray.addObject(sectionItemsArray)
//                sectionItemsArray=NSMutableArray()
//            }
//        }
//        
//        return allItemsArray
//    }
//    
//    func failureStream(_ error:NSError)
//    {
//        handleError(error)
//    }
//}
