//
//  CategoriesViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/9/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class MenuCell: UITableViewCell
{
    @IBOutlet var menuItemTitleLbl:UILabel!
    @IBOutlet var menuItemIconImageView:UIImageView!
}

class DiscoverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var tableView:UITableView!
    @IBOutlet var errorView:ErrorView!
    @IBOutlet var activityView:ActivityIndicatorView!
    @IBOutlet var selectionView:UIView!
    
    var categoriesArray=NSMutableArray()
    var channelsArray=NSMutableArray()
    var selectedTab=0
    
    override func viewDidLoad()
    {
        selectionView.frame=CGRect(x:10, y:45, width:(self.view.frame.size.width-40)/2, height:5)
        
        tableView.contentInset=UIEdgeInsetsMake(-35, 0, 0, 0)
        
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
    
    @IBAction func channels()
    {
        selectedTab=0
        tableView.reloadData()
        
        UIView.animate(withDuration:0.2, animations:{
            self.selectionView.frame=CGRect(x:10, y:45, width:(self.view.frame.size.width-40)/2, height:5)
            }, completion:nil)
    }
    
    @IBAction func categories()
    {
        selectedTab=1
        tableView.reloadData()
        
        UIView.animate(withDuration:0.2, animations:{
            self.selectionView.frame=CGRect(x:self.view.frame.size.width-self.selectionView.frame.size.width-10, y:45, width:(self.view.frame.size.width-40)/2, height:5)
            }, completion:nil)
    }
    
    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return selectedTab==0 ? 1 : 40
    }
    
    func tableView(_ tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        if selectedTab==0
        {
            return nil
        }
        else
        {
            let headerView=UIView(frame:CGRect(x:0, y:0, width:tableView.frame.size.width, height:40))
            headerView.backgroundColor=UIColor(red:34/255, green:34/255, blue:34/255, alpha:1)
            
            let titleLbl=UILabel(frame:CGRect(x:0, y:0, width:tableView.frame.size.width, height:40))
            titleLbl.text=(categoriesArray[section] as! Category).name
            titleLbl.textAlignment = .center
            titleLbl.font=UIFont.systemFont(ofSize:15)
            titleLbl.textColor=UIColor(red:190/255, green:142/255, blue:64/255, alpha:1)
            
            headerView.addSubview(titleLbl)
            
            return headerView
        }
    }
    
    func numberOfSections(in tableView:UITableView)->Int
    {
        return selectedTab==0 ? 1 : categoriesArray.count
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        let category=categoriesArray[section] as! Category
        
        return selectedTab==0 ? channelsArray.count : category.subCategories.count
    }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath)->CGFloat
    {
        return (view.frame.size.width-30)/2
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"Category") as! AllCategoryRow
        
        if selectedTab==1
        {
            let category=categoriesArray[indexPath.section] as! Category
            
            cell.sectionItemsArray=category.subCategories[indexPath.row] as! NSArray
        }
        else
        {
            cell.sectionItemsArray=channelsArray[indexPath.row] as! NSArray
        }
        
        cell.navigationControllerReference=navigationController
        
        return cell
    }
    
    func tableView(_ tableView:UITableView, willDisplay cell:UITableViewCell, forRowAt indexPath:IndexPath)
    {
        if cell is AllCategoryRow
        {
            (cell as! AllCategoryRow).reloadCollectionView()
        }
    }
    
    func discoverSuccess(data:NSDictionary)
    {
        errorView.isHidden=true
        activityView.isHidden=true
        
        let data=data["data"] as! NSDictionary
        
        let categories=data["categories"] as! NSArray
        let channels=data["channel"] as! NSArray
        
        categoriesArray.removeAllObjects()
        channelsArray.removeAllObjects()
        
        parseCategories(categories)
        parseChannels(channels)
        
        tableView.isHidden=false
        tableView.delegate=self
        tableView.dataSource=self
        tableView.reloadData()
    }
    
    func parseChannels(_ channels:NSArray)
    {
        var twoChannelsArray=NSMutableArray()
        var count=0
        
        for i in 0 ..< channels.count
        {
            let channel=channels[i] as! NSDictionary
            
            let channelObject=Category()
            channelObject.id=channel["id"] as! Int
            channelObject.name=channel["name"] as! String
            channelObject.isChannel=true
            
            twoChannelsArray.add(channelObject)
            
            count+=1
            
            if count==2||(count==1&&i==channels.count-1)
            {
                count=0
                channelsArray.add(twoChannelsArray)
                twoChannelsArray=NSMutableArray()
            }
        }
    }
    
    func parseCategories(_ categories:NSArray)
    {
        for i in 0 ..< categories.count
        {
            let category=categories[i] as! NSDictionary
            
            let categoryObject=Category()
            categoryObject.id=category["id"] as! Int
            categoryObject.name=category["name"] as! String
            
            let subCategories=category["sub-categories"] as! NSArray
            
            var twoSubCategoriesArray=NSMutableArray()
            let allSubCategoriesArray=NSMutableArray()
            var count=0
            
            for j in 0 ..< subCategories.count
            {
                let subCategory=subCategories[j] as! NSDictionary
                
                let subCategoryObject=Category()
                subCategoryObject.id=subCategory["id"] as! Int
                subCategoryObject.name=subCategory["name"] as! String
                
                twoSubCategoriesArray.add(subCategoryObject)
                
                count+=1
                
                if count==2||(count==1&&j==subCategories.count-1)
                {
                    count=0
                    allSubCategoriesArray.add(twoSubCategoriesArray)
                    twoSubCategoriesArray=NSMutableArray()
                }
            }
            
            categoryObject.subCategories=allSubCategoriesArray
            
            categoriesArray.add(categoryObject)
        }
    }
    
    func discoverFailure(error:NSError)
    {
        activityView.isHidden=true
        errorView.update("An error cccured", "user")
    }
}
