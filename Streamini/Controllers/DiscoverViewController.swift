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
    @IBOutlet var tableView:UITableView!
    @IBOutlet var errorView:ErrorView!
    @IBOutlet var activityView:ActivityIndicatorView!
    
    var allCategoriesArray=NSMutableArray()
    
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
    
    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return 1
    }

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return allCategoriesArray.count
    }
    
    func tableView(_ tableView:UITableView, heightForRowAtIndexPath indexPath:IndexPath)->CGFloat
    {
        return (view.frame.size.width-30)/2
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"Category") as! AllCategoryRow
        
        cell.sectionItemsArray=allCategoriesArray[indexPath.row] as! NSArray
        cell.navigationControllerReference=navigationController
        
        return cell
    }
    
    func tableView(_ tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:IndexPath)
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
        
        let categories=data["cat"] as! NSArray
        
        allCategoriesArray.removeAllObjects()
        
        parseCategories(categories)
        
        tableView.isHidden=false
        tableView.reloadData()
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
    
    func discoverFailure(error:NSError)
    {
        activityView.isHidden=true
        errorView.update("An error cccured", "user")
    }
}
