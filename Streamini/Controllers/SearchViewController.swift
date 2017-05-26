//
//  SearchViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 5/8/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class SearchViewController: UIViewController
{
    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var historyTbl:UITableView!
    
    let storyBoard=UIStoryboard(name:"Main", bundle:nil)
    var sectionTitlesArray=NSMutableArray()
    var TBVC:TabBarViewController!
    var searchHistroy:[NSManagedObject]!
    var brands:[User]=[]
    var agencies:[User]=[]
    var venues:[User]=[]
    var talents:[User]=[]
    var profiles:[User]=[]
    var streams:[Stream]=[]
    
    override func viewDidLoad()
    {
        searchBar.backgroundImage=UIImage()
        
        let attributes=[NSForegroundColorAttributeName:UIColor.white]
        
        if #available(iOS 9.0, *)
        {
            UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).setTitleTextAttributes(attributes, for:.normal)
        }
        
        TBVC=tabBarController as! TabBarViewController
        searchHistroy=SongManager.getSearchHistory()
        
        if searchHistroy.count>0
        {
            historyTbl.isHidden=false
        }
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        navigationController?.isNavigationBarHidden=true
    }
    
    func searchBarSearchButtonClicked(_ searchBar:UISearchBar)
    {
        SongManager.addToSearchHistory(searchBar.text!)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar:UISearchBar)
    {
        tableView.isHidden=true
        
        searchHistroy=SongManager.getSearchHistory()
        
        if searchHistroy.count>0
        {
            historyTbl.isHidden=false
            historyTbl.reloadData()
        }
        
        searchBar.showsCancelButton=false
        searchBar.text=""
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar:UISearchBar)
    {
        searchBar.showsCancelButton=true
    }
    
    func searchBar(_ searchBar:UISearchBar, textDidChange searchText:String)
    {
        StreamConnector().search(searchText, searchSuccess, searchFailure)
    }
    
    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return tableView==historyTbl ? 1 : 40
    }
    
    func tableView(_ tableView:UITableView, heightForRowAtIndexPath indexPath:IndexPath)->CGFloat
    {
        if tableView==historyTbl
        {
            return 40
        }
        else
        {
            let sectionTitle=sectionTitlesArray[indexPath.section] as! String
            
            if sectionTitle=="streams"
            {
                return indexPath.row<4 ? 80 : 40
            }
            else
            {
                return indexPath.row<4 ? 70 : 40
            }
        }
    }
    
    func tableView(_ tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        if tableView==historyTbl
        {
            return nil
        }
        else
        {
            let headerView=UIView(frame:CGRect(x:0, y:0, width:tableView.frame.size.width, height:40))
            headerView.backgroundColor=UIColor(colorLiteralRed:18/255, green:19/255, blue:21/255, alpha:1)
            
            let titleLbl=UILabel(frame:CGRect(x:15, y:15, width:285, height:20))
            titleLbl.text=(sectionTitlesArray[section] as AnyObject).uppercased
            titleLbl.font=UIFont.systemFont(ofSize: 16)
            titleLbl.textColor=UIColor.darkGray
            
            headerView.addSubview(titleLbl)
            
            return headerView
        }
    }
    
    func numberOfSectionsInTableView(_ tableView:UITableView)->Int
    {
        return tableView==historyTbl ? 1 : sectionTitlesArray.count
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if tableView==historyTbl
        {
            return searchHistroy.count>0 ? searchHistroy.count+1 : 0
        }
        else
        {
            let sectionTitle=sectionTitlesArray[section] as! String
            
            if sectionTitle=="brands"
            {
                return brands.count<4 ? brands.count : 5
            }
            else if sectionTitle=="agencies"
            {
                return agencies.count<4 ? agencies.count : 5
            }
            else if sectionTitle=="venues"
            {
                return venues.count<4 ? venues.count : 5
            }
            else if sectionTitle=="talents"
            {
                return talents.count<4 ? talents.count : 5
            }
            else if sectionTitle=="profiles"
            {
                return profiles.count<4 ? profiles.count : 5
            }
            else
            {
                return streams.count<4 ? streams.count : 5
            }
        }
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        if tableView==historyTbl
        {
            if indexPath.row<searchHistroy.count
            {
                let cell=tableView.dequeueReusableCell(withIdentifier:"SearchCell", for:indexPath)
                cell.textLabel?.text=searchHistroy[indexPath.row].value(forKey:"title") as? String
                
                cell.selectedBackgroundView=SelectedCellView().create()
                
                return cell
            }
            else
            {
                let cell=tableView.dequeueReusableCell(withIdentifier:"ClearCell", for:indexPath)
                
                cell.selectedBackgroundView=SelectedCellView().create()
                
                return cell
            }
        }
        else
        {
            let sectionTitle=sectionTitlesArray[indexPath.section] as! String
            
            if sectionTitle=="streams"
            {
                if indexPath.row<4
                {
                    let cell=tableView.dequeueReusableCell(withIdentifier:"StreamCell", for:indexPath) as! SearchStreamCell
                    let stream=streams[indexPath.row]
                    cell.update(stream)
                    
                    cell.dotsButton?.tag=indexPath.row
                    cell.dotsButton?.addTarget(self, action:#selector(dotsButtonTapped), for:.touchUpInside)
                    
                    cell.selectedBackgroundView=SelectedCellView().create()
                    
                    return cell
                }
                else
                {
                    let cell=tableView.dequeueReusableCell(withIdentifier:"SeeMoreCell", for:indexPath)
                    cell.textLabel?.text="See all \(sectionTitlesArray[indexPath.section])"
                    
                    cell.selectedBackgroundView=SelectedCellView().create()
                    
                    return cell
                }
            }
            else
            {
                if indexPath.row<4
                {
                    let cell=tableView.dequeueReusableCell(withIdentifier:"PeopleCell", for:indexPath) as! PeopleCell
                    
                    let user:User
                    
                    if sectionTitle=="brands"
                    {
                        user=brands[indexPath.row]
                    }
                    else if sectionTitle=="agencies"
                    {
                        user=agencies[indexPath.row]
                    }
                    else if sectionTitle=="venues"
                    {
                        user=venues[indexPath.row]
                    }
                    else if sectionTitle=="talents"
                    {
                        user=talents[indexPath.row]
                    }
                    else
                    {
                        user=profiles[indexPath.row]
                    }
                    
                    cell.userImageView.sd_setImage(with:user.avatarURL(), placeholderImage:UIImage(named:"profile"))
                    cell.usernameLabel.text=user.name
                    cell.likesLabel.text="\(user.followers)- FOLLOWERS - \(user.desc!)"
                    
                    cell.selectedBackgroundView=SelectedCellView().create()
                    
                    return cell
                }
                else
                {
                    let cell=tableView.dequeueReusableCell(withIdentifier:"SeeMoreCell", for:indexPath)
                    cell.textLabel?.text="See all \(sectionTitlesArray[indexPath.section])"
                    
                    cell.selectedBackgroundView=SelectedCellView().create()
                    
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAtIndexPath indexPath:IndexPath)
    {
        if tableView==historyTbl
        {
            if indexPath.row==searchHistroy.count
            {
                SongManager.deleteSearchHistory()
                historyTbl.isHidden=true
            }
            else
            {
                searchBar.text=searchHistroy[indexPath.row].value(forKey:"title") as? String
                historyTbl.isHidden=true
                tableView.isHidden=false
                StreamConnector().search(searchBar.text!, searchSuccess, searchFailure)
            }
        }
        else
        {
            let sectionTitle=sectionTitlesArray[indexPath.section] as! String
            
            if sectionTitle=="streams"
            {
                if indexPath.row<4
                {
                    let modalVC=storyBoard.instantiateViewController(withIdentifier:"ModalViewController") as! ModalViewController
                    
                    let streamsArray=NSMutableArray()
                    streamsArray.add(streams[indexPath.row])
                    
                    modalVC.streamsArray=streamsArray
                    modalVC.TBVC=TBVC
                    
                    TBVC.modalVC=modalVC
                    TBVC.configure(streams[indexPath.row])
                }
                else
                {
                    cellTapped(indexPath.section)
                }
            }
            else
            {
                if indexPath.row<4
                {
                    let vc=storyBoard.instantiateViewController(withIdentifier:"UserViewControllerId") as! UserViewController
                    
                    if sectionTitle=="brands"
                    {
                        vc.user=brands[indexPath.row]
                    }
                    else if sectionTitle=="agencies"
                    {
                        vc.user=agencies[indexPath.row]
                    }
                    else if sectionTitle=="venues"
                    {
                        vc.user=venues[indexPath.row]
                    }
                    else if sectionTitle=="talents"
                    {
                        vc.user=talents[indexPath.row]
                    }
                    else
                    {
                        vc.user=profiles[indexPath.row]
                    }
                    
                    navigationController?.pushViewController(vc, animated:true)
                }
                else
                {
                    cellTapped(indexPath.section)
                }
            }
        }
    }
    
    func searchSuccess(brands:[User], agencies:[User], venues:[User], talents:[User], profiles:[User], streams:[Stream])
    {
        sectionTitlesArray.removeAllObjects()
        
        if brands.count>0
        {
            sectionTitlesArray.add("brands")
            self.brands=brands
        }
        if agencies.count>0
        {
            sectionTitlesArray.add("agencies")
            self.agencies=agencies
        }
        if venues.count>0
        {
            sectionTitlesArray.add("venues")
            self.venues=venues
        }
        if talents.count>0
        {
            sectionTitlesArray.add("talents")
            self.talents=talents
        }
        if profiles.count>0
        {
            sectionTitlesArray.add("profiles")
            self.profiles=profiles
        }
        if streams.count>0
        {
            sectionTitlesArray.add("streams")
            self.streams=streams
        }
        
        tableView.isHidden=false
        historyTbl.isHidden=true
        tableView.reloadData()
    }
    
    func searchFailure(error:NSError)
    {
        
    }
    
    func cellTapped(_ section:Int)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"SeeMoreViewController") as! SeeMoreViewController
        vc.t=sectionTitlesArray[section] as! String
        vc.q=searchBar.text
        vc.TBVC=TBVC
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func dotsButtonTapped(sender:UIButton)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"PopUpViewController") as! PopUpViewController
        vc.stream=streams[sender.tag]
        present(vc, animated:true)
    }
}
