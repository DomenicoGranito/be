//
//  RecentStreamsDataSource.swift
//  Streamini
//
//  Created by Vasily Evreinov on 07/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class RecentStreamsDataSource:UserStatisticsDataSource
{
    var streams:[Stream]=[]
    
    override func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return streams.count
    }
    
    override func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath)->UITableViewCell
    {
        let stream=streams[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier:"RecentStreamCell", for:indexPath) as! RecentStreamCell
        
        cell.dotsButton?.tag=indexPath.row
        cell.dotsButton?.addTarget(self, action:#selector(dotsButtonTapped), for:.touchUpInside)
        
        cell.selectedBackgroundView=SelectedCellView().create()
        
        cell.update(stream)
        return cell
    }
    
    func dotsButtonTapped(_ sender:UIButton)
    {
        streamSelectedDelegate.openPopUpForSelectedStream(streams[sender.tag])
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAtIndexPath indexPath:IndexPath)
    {
        tableView.deselectRow(at:indexPath, animated:true)
        
        streamSelectedDelegate.streamDidSelected(streams[indexPath.row])
    }
    
    func recentSuccess(_ streams:[Stream])
    {
        if let pullToRefreshView=tableView.pullToRefreshView
        {
            pullToRefreshView.stopAnimating()
        }
        
        self.streams=streams
        
        //tableView.isHidden=self.streams.isEmpty
        let range=NSMakeRange(0, tableView.numberOfSections)
        let indexSet=NSIndexSet(indexesIn:range)
        tableView.reloadSections(indexSet as IndexSet, with:.automatic)
    }

    func recentFailure(error:NSError)
    {
        if let pullToRefreshView=tableView.pullToRefreshView
        {
            pullToRefreshView.stopAnimating()
        }
    }
    
    override func reload()
    {
        StreamConnector().recent(userId, recentSuccess, recentFailure)
    }
        
    override func clean()
    {
        streams=[]
        tableView.reloadData()
    }
}
