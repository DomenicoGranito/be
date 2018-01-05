//
//  HomeViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/8/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class HomeViewController: BaseViewController
{
    @IBOutlet var itemsTbl:UITableView!
    @IBOutlet var errorView:ErrorView!
    @IBOutlet var activityView:ActivityIndicatorView!
    @IBOutlet var headerView:GSKStretchyHeaderView!
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var pageControl:UIPageControl!
    
    var categoryNamesArray=NSMutableArray()
    var categoryIDsArray=NSMutableArray()
    var allCategoryItemsArray=NSMutableArray()
    var timer:Timer?
    let site=Config.shared.site()
    let pageWidth=UIScreen.main.bounds.width
    
    override func viewDidLoad()
    {
        Timer.scheduledTimer(timeInterval:5, target:self, selector:#selector(moveToNextPage), userInfo:nil, repeats:true)
        
        NotificationCenter.default.addObserver(self, selector:#selector(updateUI), name:Notification.Name("refreshAfterBlock"), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(updateUI), name:Notification.Name("status"), object:nil)
        
        itemsTbl.addSubview(headerView)
        
        setUPHeader()
        
        updateUI()
    }
    
    func setUPHeader()
    {
        scrollView.frame=CGRect(x:0, y:0, width:pageWidth, height:300)
        
        let imgOne=UIImageView(frame:CGRect(x:pageWidth, y:0, width:pageWidth, height:300))
        imgOne.autoresizingMask=[.flexibleHeight]
        imgOne.sd_setImage(with:URL(string:"\(site)/media/featured/1.jpg"))
        
        let imgTwo=UIImageView(frame:CGRect(x:2*pageWidth, y:0, width:pageWidth, height:300))
        imgTwo.autoresizingMask=[.flexibleHeight]
        imgTwo.sd_setImage(with:URL(string:"\(site)/media/featured/2.jpg"))
        
        let imgThree=UIImageView(frame:CGRect(x:0, y:0, width:pageWidth, height:300))
        imgThree.autoresizingMask=[.flexibleHeight]
        imgThree.sd_setImage(with:URL(string:"\(site)/media/featured/3.jpg"))
        
        let imgFour=UIImageView(frame:CGRect(x:3*pageWidth, y:0, width:pageWidth, height:300))
        imgFour.autoresizingMask=[.flexibleHeight]
        imgFour.sd_setImage(with:URL(string:"\(site)/media/featured/3.jpg"))
        
        let imgFive=UIImageView(frame:CGRect(x:4*pageWidth, y:0, width:pageWidth, height:300))
        imgFive.autoresizingMask=[.flexibleHeight]
        imgFive.sd_setImage(with:URL(string:"\(site)/media/featured/1.jpg"))
        
        scrollView.addSubview(imgThree)
        scrollView.addSubview(imgOne)
        scrollView.addSubview(imgTwo)
        scrollView.addSubview(imgFour)
        scrollView.addSubview(imgFive)
        
        scrollView.contentSize=CGSize(width:pageWidth*5, height:300)
        scrollView.scrollRectToVisible(CGRect(x:pageWidth, y:0, width:pageWidth, height:300), animated:false)
        pageControl.currentPage=0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView:UIScrollView)
    {
        if scrollView.contentOffset.x==0
        {
            scrollView.scrollRectToVisible(CGRect(x:3*pageWidth, y:0, width:pageWidth, height:300), animated:false)
        }
        else if scrollView.contentOffset.x==1280
        {
            scrollView.scrollRectToVisible(CGRect(x:pageWidth, y:0, width:pageWidth, height:300), animated:false)
        }
        
        let currentPage=floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)
        
        pageControl.currentPage=Int(currentPage)
    }
    
    func scrollViewDidScroll(_ scrollView:UIScrollView)
    {
        if scrollView==itemsTbl
        {
            headerView?.alpha = -scrollView.contentOffset.y/300
            
            if scrollView.contentOffset.y >= -64
            {
                navigationController?.isNavigationBarHidden=false
            }
            else
            {
                navigationController?.isNavigationBarHidden=true
            }
        }
    }
    
    func moveToNextPage()
    {
        let slideToX=scrollView.contentOffset.x+pageWidth
        
        if scrollView.contentOffset.x>640
        {
            scrollView.scrollRectToVisible(CGRect(x:pageWidth, y:0, width:pageWidth, height:300), animated:false)
            
            pageControl.currentPage=0
            
            return
        }
        
        scrollView.scrollRectToVisible(CGRect(x:slideToX, y:0, width:pageWidth, height:300), animated:true)
        
        let currentPage=scrollView.contentOffset.x/pageWidth
        
        pageControl.currentPage=Int(currentPage)
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
        return 200
    }
    
    func tableView(_ tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRect(x:0, y:0, width:tableView.frame.size.width, height:200))
        headerView.backgroundColor=UIColor(red:18/255, green:19/255, blue:21/255, alpha:1)
        
        let titleLbl=UILabel(frame:CGRect(x:10, y:10, width:view.frame.size.width-20, height:180))
        
        if(allCategoryItemsArray.count>0)
        {
            titleLbl.text=(categoryNamesArray[section] as AnyObject).uppercased
        }
        
        titleLbl.font=UIFont.systemFont(ofSize:24)
        titleLbl.textColor=UIColor.white
        titleLbl.textAlignment = .center
        
        let categoryImageView=UIImageView(frame:CGRect(x:0, y:0, width:view.frame.size.width, height:200))
        categoryImageView.sd_setImage(with:URL(string:"\(site)/media/categories/\(categoryIDsArray[section]).jpg"))
        
        let tapGesture=UITapGestureRecognizer(target:self, action:#selector(headerTapped))
        headerView.addGestureRecognizer(tapGesture)
        headerView.tag=section
        
        headerView.addSubview(categoryImageView)
        headerView.addSubview(titleLbl)
        
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
                
                let oneVideo=Stream()
                oneVideo.id=video["id"] as! Int
                oneVideo.vType=video["vtype"] as! Int
                oneVideo.videoID=video["streamkey"] as! String
                oneVideo.title=video["title"] as! String
                oneVideo.streamHash=video["hash"] as! String
                oneVideo.lon=video["lon"] as! Double
                oneVideo.lat=video["lat"] as! Double
                oneVideo.city=video["city"] as! String
                
                if let e=video["ended"] as? String
                {
                    oneVideo.ended=NSDate(timeIntervalSince1970:Double(e)!)
                }
                
                oneVideo.viewers=video["viewers"] as! Int
                oneVideo.tviewers=video["tviewers"] as! Int
                oneVideo.rviewers=video["rviewers"] as! Int
                oneVideo.likes=video["likes"] as! Int
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
