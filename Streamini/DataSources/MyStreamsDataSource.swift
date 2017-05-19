//
//  MyStreamsDataSource.swift
// Streamini
//
//  Created by Vasily Evreinov on 24/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class MyStreamsDataSource: RecentStreamsDataSource
{
    override func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier: "RecentStreamCell", for:indexPath as IndexPath) as! RecentStreamCell
        let stream=streams[indexPath.row]
        cell.updateMyStream(stream)
        
        return cell
    }
    
    func myRecentSuccess(_ streams:[Stream])
    {
        recentSuccess(streams.filter{$0.vType==vType})
    }
    
    override func reload()
    {
        StreamConnector().recent(userId, success:myRecentSuccess, failure:recentFailure)
    }
    
    override func fetchMore()
    {
        
    }
    
    func tableView(_ tableView:UITableView, canEditRowAtIndexPath indexPath:NSIndexPath)->Bool
    {
        return true
    }
    
    func tableView(_ tableView:UITableView, commitEditingStyle editingStyle:UITableViewCellEditingStyle, forRowAtIndexPath indexPath:NSIndexPath)
    {
        if editingStyle == .delete
        {
            StreamConnector().del(streams[indexPath.row].id, success:delSuccess, failure:delFailure)
            self.streams.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath as IndexPath], with:.automatic)
        }
    }
    
    func delSuccess()
    {
        
    }
    
    func delFailure(_ error:NSError)
    {
        //handleError(error)
    }
}
