//
//  PopularStreamsDataSource.swift
//  Streamini
//
//  Created by Ankit Garg on 8/1/18.
//  Copyright © 2018 Cedricm Video. All rights reserved.
//

class PopularStreamsDataSource:UserStatisticsDataSource
{
    var streams:NSArray!
    
    override func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return 40
    }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath)->CGFloat
    {
        return 155
    }
    
    func tableView(_ tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRect(x:0, y:0, width:tableView.frame.size.width, height:40))
        headerView.backgroundColor=UIColor(red:18/255, green:19/255, blue:21/255, alpha:1)
        
        let titleLbl=UILabel(frame:CGRect(x:0, y:10, width:tableView.frame.size.width, height:20))
        titleLbl.text="POPULAR"
        titleLbl.textAlignment = .center
        titleLbl.font=UIFont.systemFont(ofSize:14)
        titleLbl.textColor = .darkGray
        
        headerView.addSubview(titleLbl)
        
        return headerView
    }
    
    override func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return streams.count
    }
    
    override func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"PopularStreamCell", for:indexPath) as! PopularStreamCell
        
        tableView.separatorStyle = .none
        cell.streams=streams[indexPath.row] as! NSArray
        cell.streamSelectedDelegate=streamSelectedDelegate
        
        return cell
    }
    
    func tableView(_ tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:IndexPath)
    {
        let cell=cell as! PopularStreamCell
        
        cell.reloadCollectionView()
    }
    
    func recentSuccess(_ streams:[Stream])
    {
        if let pullToRefreshView=tableView.pullToRefreshView
        {
            pullToRefreshView.stopAnimating()
        }
        
        self.streams=streams.chunked(into:2)
        
        tableView.reloadData()
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

extension Array
{
    func chunked(into size:Int)->NSArray
    {
        return stride(from:0, to:count, by:size).map
        {
            Array(self[$0..<Swift.min($0+size, count)])
        } as NSArray
    }
}
