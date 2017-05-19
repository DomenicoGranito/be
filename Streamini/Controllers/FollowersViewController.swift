//
//  FollowersViewController.swift
// Streamini
//
//  Created by Vasily Evreinov on 22/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

protocol SelectFollowersDelegate: class {
    func followersDidSelected(_ users: [User])
}

class FollowersViewController: BaseViewController, UISearchBarDelegate, UserSelecting
{
    @IBOutlet var tableView:UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    var users: [User]           = []
    var selectedUsers: [User]   = []
    var page                    = 0
    var searchTerm              = ""
    weak var delegate: SelectFollowersDelegate?
    
    // MARK: - Actions
    
    func selectedDone() {
        if let del = delegate {
            if !selectedUsers.isEmpty {
                del.followersDidSelected(selectedUsers)
            }
        }
        self.navigationController!.popViewController(animated: true)
    }
    
    // MARK: - Network responses
    
    func followersSuccess(_ users: [User]) {
        self.users = users.filter( { $0.id != UserContainer.shared.logged().id } )
        
        let range = NSMakeRange(0, tableView.numberOfSections)
        let indexSet = NSIndexSet(indexesIn: range)
        tableView.reloadSections(indexSet as IndexSet, with:.automatic)
    }
    
    func addFollowersSuccess(_ users: [User]) {
        tableView.infiniteScrollingView.stopAnimating()
        self.users += users.filter( { $0.id != UserContainer.shared.logged().id } )
        tableView.reloadData()
    }
    
    func followersFailure(_ error: NSError) {
        handleError(error)
        tableView.infiniteScrollingView.stopAnimating()
    }
    
    func userDidSelected(_ user:User)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewController(withIdentifier: "UserViewControllerId") as! UserViewController
        vc.user=user
        navigationController?.pushViewController(vc, animated:true)
    }
    
    // MARK: - View life cycle
    
    func configureView() {
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.title = NSLocalizedString("select_followers_title", comment: "")
        
        let buttonItem = UIBarButtonItem(barButtonSystemItem:.done, target: self, action: #selector(FollowersViewController.selectedDone))
        self.navigationItem.rightBarButtonItem = buttonItem
        
        self.tableView.addInfiniteScrolling { () -> Void in
            self.page += 1
            let data = NSDictionary(objects: [self.page, self.searchTerm], forKeys: ["p" as NSCopying, "q" as NSCopying])
            UserConnector().followers(data, success: self.addFollowersSuccess, failure: self.followersFailure)
        }
        
        self.searchBar.placeholder = NSLocalizedString("search_followers_placeholder", comment: "")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureView()
        
        let data = [ "p" : page ]
        UserConnector().followers(data as NSDictionary, success: followersSuccess, failure: followersFailure)
    }
    
    // MARK: - UITableView Delegate & DataSource
    
    func numberOfSectionsInTableView(_ tableView:UITableView)->Int
    {
        return 1
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return users.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "followerCell", for: indexPath as IndexPath) as! FollowerCell
        cell.userSelectedDelegate = self
        cell.update(user)
        
        return cell        
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let user = users[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath as IndexPath) as! FollowerCell

        if selectedUsers.filter({ $0.id == user.id }).count > 0 {
            cell.checkmarkImageView.isHidden = true
            selectedUsers = selectedUsers.filter({ $0.id != user.id })
        } else {
            cell.checkmarkImageView.isHidden = false
            selectedUsers.append(user)
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        page = 0
        searchTerm = searchText
        let data = NSDictionary(objects: [page, searchTerm], forKeys: ["p" as NSCopying, "q" as NSCopying])
        UserConnector().followers(data, success: followersSuccess, failure: followersFailure)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        let data = [ "p" : 0 ]
        UserConnector().followers(data as NSDictionary, success: followersSuccess, failure: followersFailure)
        
        page            = 0
        searchTerm      = ""
        searchBar.text  = ""
        searchBar.resignFirstResponder()
    }
}
