//
//  FollowingDataSource.swift
//  Streamini
//
//  Created by Vasily Evreinov on 07/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class FollowingDataSource: UserStatisticsDataSource
{
    override func reload()
    {
        UserConnector().following(NSDictionary(object:userId, forKey:"id" as NSCopying), statisticsDataSuccess, statisticsDataFailure)
    }
    
    override func fetchMore()
    {
        page+=1
        let dictionary=NSDictionary(objects:[userId, page], forKeys:["id" as NSCopying, "p" as NSCopying])
        UserConnector().following(dictionary, moreStatisticsDataSuccess, statisticsDataFailure)
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAtIndexPath indexPath:IndexPath)
    {
        tableView.deselectRow(at:indexPath, animated:true)
        
        let user=users[indexPath.row]
        
        if let delegate=userSelectedDelegate
        {
            delegate.userDidSelected(user)
        }
    }
}
