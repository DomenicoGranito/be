//
//  CategoriesViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/9/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class MenuCell: UITableViewCell
{
    @IBOutlet var menuItemTitleLbl:UILabel?
    @IBOutlet var menuItemIconImageView:UIImageView?
}

class DiscoverViewController: UIViewController
{
    @IBOutlet var tableView:GradientTableView!
    @IBOutlet var errorView:ErrorView!
    @IBOutlet var activityView:ActivityIndicatorView!
    
    var allCategoriesArray=NSMutableArray()
    var featuredStreamsArray=NSMutableArray()
    var menuItemTitlesArray=["Channels"]
    var menuItemIconsArray=["videochannel"]
    
    override func viewDidLoad()
    {
        NotificationCenter.default.addObserver(self, selector:#selector(updateUI), name:Notification.Name("status"), object:nil)
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        navigationController?.isNavigationBarHidden=false
    }
    
    func updateUI()
    {
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.reachability.isReachable
        {
            errorView.isHidden=true
            activityView.isHidden=false
            
            StreamConnector().discover(discoverSuccess, discoverFailure)
        }
        else
        {
            tableView.isHidden=true
            activityView.isHidden=true
            errorView.update("No Internet Connection", "user")
        }
    }
    
    func numberOfSectionsInTableView(_ tableView:UITableView)->Int
    {
        return 3
    }
    
    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return section>1 ? 60 : 1
    }
    
    func tableView(_ tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        if section==2
        {
            let headerView=UIView(frame:CGRect(x:0, y:0, width:tableView.frame.size.width, height:60))
            headerView.backgroundColor=UIColor(colorLiteralRed:18/255, green:19/255, blue:21/255, alpha:1)
            
            let titleLbl=UILabel(frame:CGRect(x:10, y:30, width:285, height:20))
            titleLbl.text="GENRES & MOODS"
            titleLbl.font=UIFont.systemFont(ofSize:24)
            titleLbl.textColor=UIColor(colorLiteralRed:190/255, green:142/255, blue:64/255, alpha:1)
            
            let lineView=UIView(frame:CGRect(x:10, y:59.5, width:tableView.frame.size.width-20, height:0.5))
            lineView.backgroundColor=UIColor(colorLiteralRed:37/255, green:36/255, blue:41/255, alpha:1)
            
            headerView.addSubview(lineView)
            headerView.addSubview(titleLbl)
            
            return headerView
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if section==0
        {
            return 1
        }
        else if section==1
        {
            return 1
        }
        else
        {
            return allCategoriesArray.count
        }
    }
    
    func tableView(_ tableView:UITableView, heightForRowAtIndexPath indexPath:IndexPath)->CGFloat
    {
        if indexPath.section==0
        {
            return (view.frame.size.width-25)/2+125
        }
        else if indexPath.section==1
        {
            return 50
        }
        else
        {
            return (view.frame.size.width-30)/2
        }
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        if indexPath.section==0&&featuredStreamsArray.count>0
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"Recent") as! CategoryRow
            
            cell.oneCategoryItemsArray=featuredStreamsArray
            cell.TBVC=tabBarController as! TabBarViewController
            cell.cellIdentifier="videoCell"
            
            return cell
        }
        if indexPath.section==1
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"Menu") as! MenuCell
            
            cell.menuItemTitleLbl?.text=menuItemTitlesArray[indexPath.row]
            cell.menuItemIconImageView?.image=UIImage(named:menuItemIconsArray[indexPath.row])
            
            return cell
        }
        if indexPath.section==2
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"Category") as! AllCategoryRow
            
            cell.sectionItemsArray=allCategoriesArray[indexPath.row] as! NSArray
            cell.navigationControllerReference=navigationController
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:IndexPath)
    {
        if cell is AllCategoryRow
        {
            (cell as! AllCategoryRow).reloadCollectionView()
        }
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAtIndexPath indexPath:IndexPath)
    {
        if indexPath.section==1&&indexPath.row==0
        {
            performSegue(withIdentifier:"Channels", sender:nil)
        }
    }
    
    func discoverSuccess(data:NSDictionary)
    {
        errorView.isHidden=true
        activityView.isHidden=true
        
        let data=data["data"] as! NSDictionary
        
        let videos=data["feat"] as! NSArray
        let categories=data["cat"] as! NSArray
        
        featuredStreamsArray.removeAllObjects()
        allCategoriesArray.removeAllObjects()
        
        parseFeaturedStreams(videos)
        parseCategories(categories)
        
        tableView.isHidden=false
        tableView.reloadData()
        
        getImage()
    }
    
    func parseFeaturedStreams(_ videos:NSArray)
    {
        for j in 0 ..< videos.count
        {
            let video=videos[j] as! NSDictionary
            
            let videoID=video["id"] as! Int
            let vType=video["vtype"] as! Int
            let streamKey=video["streamkey"] as! String
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
            
            featuredStreamsArray.add(oneVideo)
        }
    }
    
    func parseCategories(_ cats:NSArray)
    {
        var sectionItemsArray=NSMutableArray()
        var count=0
        
        for i in 0 ..< cats.count
        {
            let cat=cats[i] as! NSDictionary
            
            let categoryID=cat["id"] as! Int
            let categoryName=cat["name"] as! String
            
            let category=Category()
            category.id=UInt(categoryID)
            category.name=categoryName
            
            sectionItemsArray.add(category)
            
            count+=1
            
            if count==2||(count==1&&i==cats.count-1)
            {
                count=0
                allCategoriesArray.add(sectionItemsArray)
                sectionItemsArray=NSMutableArray()
            }
        }
    }
    
    func getImage()
    {
        DispatchQueue.global().async
            {
                let (host, _, _, _, _)=Config.shared.wowza()
                let stream=self.featuredStreamsArray[0] as! Stream
                let url=URL(string:"http://\(host)/thumb/\(stream.id).jpg")
                let data=try! Data(contentsOf:url!)
                
                DispatchQueue.main.async(execute:
                    {
                        self.tableView.createGradientLayer(UIImage(data:data)!)
                })
        }
    }
    
    func discoverFailure(error:NSError)
    {
        activityView.isHidden=true
        errorView.update("An error cccured", "user")
    }
}
