//
//  ChannelsTableViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/23/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

protocol ProfileDelegate:class
{
    func reload()
    func close()
}

class ChannelsTableViewController: UITableViewController, ProfileDelegate
{
    @IBOutlet var followingValueLabel:UILabel!
    @IBOutlet var followersValueLabel:UILabel!
    @IBOutlet var blockedValueLabel:UILabel!
    
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask
    {
        return .portrait
    }
    
    override var shouldAutorotate:Bool
    {
        return false
    }
    
    override func viewDidLoad()
    {
        let activator=UIActivityIndicatorView(activityIndicatorStyle:.white)
        activator.startAnimating()
        
        navigationItem.rightBarButtonItem=UIBarButtonItem(customView:activator)
        UserConnector().get(nil, userSuccess, userFailure)
    }
    
    func userSuccess(user:User)
    {
        followingValueLabel.text="\(user.following)"
        followersValueLabel.text="\(user.followers)"
        blockedValueLabel.text="\(user.blocked)"
        
        navigationItem.rightBarButtonItem=nil
    }
    
    func userFailure(error:NSError)
    {
        
    }
    
    override func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath)->UITableViewCell
    {
        let cell=super.tableView(tableView, cellForRowAt:indexPath)
        
        cell.selectedBackgroundView=SelectedCellView().create()
        
        return cell
    }

    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath)
    {
        tableView.deselectRow(at:indexPath, animated:true)
        
        performSegue(withIdentifier:"GoToUsers", sender:indexPath)
    }

    override func prepare(for segue:UIStoryboardSegue, sender:Any?)
    {
        let controller=segue.destination as! ProfileStatisticsViewController
        let index=(sender as! IndexPath).row
        controller.type=ProfileStatisticsType(rawValue:index)!
        controller.profileDelegate=self
    }
    
    func reload()
    {
        UserConnector().get(nil, userSuccess, userFailure)
    }
    
    func close()
    {
        
    }
}
