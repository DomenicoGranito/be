//
//  RecentUsersDataSource.swift
//  Streamini
//
//  Created by Vasily Evreinov on 07/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class RecentStreamsDataSource:UserStatisticsDataSource
{
    var streams:[Stream]=[]
    
    override func numberOfSections(in tableView:UITableView)->Int
    {
        return 1
    }
    
    override func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return 40
    }

    func tableView(_ tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRect(x:0, y:0, width:tableView.frame.size.width, height:40))
        headerView.backgroundColor=UIColor(red:18/255, green:19/255, blue:21/255, alpha:1)
        
        let titleLbl=UILabel(frame:CGRect(x:5, y:10, width:150, height:20))
        titleLbl.text="ALL VIDEOS"
        titleLbl.font=UIFont.systemFont(ofSize:14)
        titleLbl.textColor=UIColor.lightGray
        
        let filterButton=UIButton(frame:CGRect(x:tableView.frame.size.width-25, y:10, width:20, height:20))
        filterButton.setImage(UIImage(named:"menu"), for:.normal)
        
        let lineView=UIView(frame:CGRect(x:0, y:39, width:tableView.frame.size.width, height:1))
        lineView.backgroundColor=UIColor.darkGray
        
        headerView.addSubview(lineView)
        headerView.addSubview(titleLbl)
        headerView.addSubview(filterButton)
        
        return headerView
    }

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
        if let delegate=streamSelectedDelegate
        {
            delegate.openPopUpForSelectedStream(streams[sender.tag])
        }
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAtIndexPath indexPath:IndexPath)
    {
        tableView.deselectRow(at:indexPath, animated:true)
        
        if let delegate=streamSelectedDelegate
        {
            delegate.streamDidSelected(streams[indexPath.row])
        }
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
    
    override func fetchMore()
    {
        
    }
    
    override func clean()
    {
        streams=[]
        tableView.reloadData()
    }
}
