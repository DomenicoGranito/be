//
//  PeopleViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 10/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class PeopleViewController: BaseViewController, UserSelecting, ProfileDelegate, UISearchBarDelegate, UserStatusDelegate
{
    var dataSource: PeopleDataSource?
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchBarTop: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyLabel: UILabel!
    
    var isSearchMode=true
    
    func showSearch(_ animated:Bool)
    {
        if !isSearchMode
        {
            if animated {
                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                    self.searchBarTop.constant = 0
                    self.view.layoutIfNeeded()
                })
            } else {
                self.searchBarTop.constant = 0
                self.view.layoutIfNeeded()
            }
            isSearchMode = true
            searchBar.becomeFirstResponder()
        }
    }
    
    func hideSearch(_ animated:Bool)
    {
        if isSearchMode
        {
            if animated {
                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                    self.searchBarTop.constant = -self.searchBar.bounds.size.height
                    self.view.layoutIfNeeded()
                })
            } else {
                self.searchBarTop.constant = -44
                self.view.layoutIfNeeded()
            }
            isSearchMode = false
            dataSource!.isSearchMode = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar:UISearchBar)
    {
        hideSearch(true)
        dataSource!.reload()
    }
    
    func searchBar(_ searchBar:UISearchBar, textDidChange searchText:String)
    {
        if searchText.characters.count>1
        {
            let data=NSDictionary(dictionary:["p":0, "q":searchText])
            dataSource!.isSearchMode=true
            dataSource!.search(data)
        }
    }
    
    func configureView()
    {
        emptyLabel.text=NSLocalizedString("table_no_data", comment:"")
        
        tableView.tableFooterView=UIView()
        
        tableView.addPullToRefresh{()->() in
            self.dataSource!.reload()
        }
        
        tableView.addInfiniteScrolling{()->() in
            self.dataSource!.fetchMore()
        }
        
        self.dataSource=PeopleDataSource(tableView:tableView)
        dataSource!.userSelectedDelegate=self
        hideSearch(false)
    }
    
    override func viewDidLoad()
    {
        configureView()
        
        dataSource!.reload()
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        navigationController?.isNavigationBarHidden=false
    }
    
    func reload()
    {
        dataSource!.reload()
    }
    
    func close()
    {
        
    }    
    
    func followStatusDidChange(_ status:Bool, user:User)
    {
        dataSource!.updateUser(user, isFollowed:status, isBlocked:user.isBlocked)
    }
    
    func blockStatusDidChange(_ status:Bool, user:User)
    {
        dataSource!.updateUser(user, isFollowed:user.isFollowed, isBlocked:status)
    }
    
    func userDidSelected(_ user:User)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"UserViewControllerId") as! UserViewController
        vc.user=user
        navigationController?.pushViewController(vc, animated:true)
        
        searchBar.resignFirstResponder()
    }
}
