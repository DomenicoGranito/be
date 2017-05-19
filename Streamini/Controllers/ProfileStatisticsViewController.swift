//
//  ProfileStatisticsViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 19/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

enum ProfileStatisticsType:Int
{
    case following = 0
    case followers
    case blocked
    case streams
}

class ProfileStatisticsViewController: UIViewController, UserSelecting, UserStatusDelegate
{
    @IBOutlet var tableView:UITableView!
    @IBOutlet var emptyLabel:UILabel!
    var dataSource:UserStatisticsDataSource?
    var type:ProfileStatisticsType = .following
    var profileDelegate:ProfileDelegate?
    var vType:Int!
    
    func configureView()
    {
        emptyLabel.text=NSLocalizedString("table_no_data", comment:"")
        
        switch type
        {
        case .following:    title=NSLocalizedString("profile_following", comment:"")
        case .followers:    title=NSLocalizedString("profile_followers", comment:"")
        case .blocked:      title=NSLocalizedString("profile_blocked", comment:"")
        case .streams:      title=NSLocalizedString("profile_streams", comment:"")
        }
        
        tableView.tableFooterView=UIView()
        
        tableView.addPullToRefresh
            {()->Void in
            self.dataSource!.reload()
        }
        
        if type != .streams
        {
            tableView.addInfiniteScrolling
                {()->Void in
                self.dataSource!.fetchMore()
            }
        }
    }
    
    override func viewDidLoad()
    {
        configureView()
        
        let userId=UserContainer.shared.logged().id
        dataSource=UserStatisticsDataSource.create(type, userId:userId, tableView:tableView)
        dataSource!.profileDelegate=profileDelegate
        dataSource!.userSelectedDelegate=self
        dataSource!.type=type
        dataSource!.vType=vType
        dataSource!.reload()
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        navigationController?.isNavigationBarHidden=false
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender:Any?)
    {
        if let sid=segue.identifier
        {
            if sid=="ProfileStatisticsToJoinStream"
            {
                let navigationController=segue.destination as! UINavigationController
                let controller=navigationController.viewControllers[0] as! JoinStreamViewController
                controller.stream=(sender as! StreamCell).stream
                controller.isRecent=true
            }
        }
    }
    
    func userDidSelected(_ user:User)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewController(withIdentifier: "UserViewControllerId") as! UserViewController
        vc.user=user
        navigationController!.pushViewController(vc, animated:true)
    }
    
    func followStatusDidChange(_ status:Bool, user:User)
    {
        dataSource!.updateFollowedStatus(user, status:status)
        profileDelegate!.reload()
    }
    
    func blockStatusDidChange(_ status:Bool, user:User)
    {
        dataSource!.updateBlockedStatus(user, status:status)
        profileDelegate!.reload()
    }
}
