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
    @IBOutlet var selectionView:UIView!
    
    var categoriesArray=NSMutableArray()
    
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
    
    @IBAction func channels()
    {
        UIView.animate(withDuration:0.2, animations:{
            self.selectionView.frame=CGRect(x:10, y:45, width:(self.view.frame.size.width-40)/2, height:5)
            }, completion:nil)
    }
    
    @IBAction func categories()
    {
        UIView.animate(withDuration:0.2, animations:{
            self.selectionView.frame=CGRect(x:self.view.frame.size.width-self.selectionView.frame.size.width-10, y:45, width:(self.view.frame.size.width-40)/2, height:5)
            }, completion:nil)
    }
    
    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return 40
    }

    func numberOfSectionsInTableView(_ tableView:UITableView)->Int
    {
        return categoriesArray.count
    }

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        let category=categoriesArray[section] as! Category
        
        return category.subCategories.count
    }
    
    func tableView(_ tableView:UITableView, heightForRowAtIndexPath indexPath:IndexPath)->CGFloat
    {
        return (view.frame.size.width-30)/2
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"Category") as! AllCategoryRow
        
        let category=categoriesArray[indexPath.section] as! Category
        
        cell.sectionItemsArray=category.subCategories[indexPath.row] as! NSArray
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
        
        let categories=data["categories"] as! NSArray
        
        categoriesArray.removeAllObjects()
        
        parseCategories(categories)
        
        tableView.isHidden=false
        tableView.reloadData()
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
