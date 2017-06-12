//
//  VideosTableViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/23/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class VideosTableViewController: UITableViewController, ProfileDelegate
{
    @IBOutlet var myLbl:UILabel!
    @IBOutlet var favouritesCountLbl:UILabel!
    @IBOutlet var myCountLbl:UILabel!
    
    var vType:Int!
    
    // MARK: - Orientation Handling.
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad()
    {
        if vType==1
        {
            self.title="VIDEOS"
            myLbl.text="My Videos"
        }
        
        UserConnector().get(nil, userSuccess, userFailure)
    }
    
    func userSuccess(user:User)
    {
        myCountLbl.text="\(user.streams)"
        favouritesCountLbl.text="\(SongManager.getFavourites(vType).count)"
    }
    
    func userFailure(error:NSError)
    {
        
    }

    override func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if vType==1
        {
            return 4
        }
        
        return 2
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
        
        var identifier:String!
        
        if indexPath.row==0
        {
            identifier="GoToFavourites"
            performSegue(withIdentifier:identifier, sender:nil)
        }
        else if indexPath.row==1
        {
            identifier="GoToMy"
            performSegue(withIdentifier:identifier, sender:nil)
        }
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender:Any?)
    {
        if segue.identifier=="GoToFavourites"
        {
            let controller=segue.destination as! VideosViewController
            controller.vType=vType
        }
        else if segue.identifier=="GoToMy"
        {
            let controller=segue.destination as! ProfileStatisticsViewController
            controller.type=ProfileStatisticsType(rawValue:3)!
            controller.profileDelegate=self
            controller.vType=vType
        }
    }
    
    func reload()
    {
        UserConnector().get(nil, userSuccess, userFailure)
    }
    
    func close()
    {
        
    }
}
