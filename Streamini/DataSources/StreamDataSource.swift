//
//  StreamDataSource.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class StreamDataSource: NSObject, UITableViewDataSource, UITableViewDelegate
{
    var lives: [Stream]     = []
    var recent: [Stream]    = []
    var userSelectedDelegate: UserSelecting?
    fileprivate let l = UILabel()
    
    override init() {
        super.init()
        l.font = UIFont(name: "HelveticNeue-Light", size: 17.0)
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
    }

    func numberOfSections(in tableView:UITableView)->Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? lives.count : recent.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath)->UITableViewCell
    {
        let identifier = (indexPath.section == 0) ? "LiveStreamCell" : "RecentStreamCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath as IndexPath) as! StreamCell
        let stream = (indexPath.section == 0) ? lives[indexPath.row] : recent[indexPath.row]

        if let delegate = self.userSelectedDelegate {
            cell.userSelectedDelegate = delegate
        }
        cell.update(stream)
        
        if indexPath.section == 0 {
            //cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || recent.isEmpty {
            return nil
        }
        let header=UIView(frame:CGRect(x:0, y:0, width:tableView.bounds.size.width, height:35))
        header.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        let label = UILabel()
        label.text = NSLocalizedString("recent_streams", comment: "")
        label.font = UIFont(name: "HelveticaNeue", size: 17.0)
        label.frame=CGRect(x:14, y:0, width:tableView.bounds.size.width-14, height:35)
        label.textColor = UIColor.darkGray
        label.backgroundColor = UIColor.clear
        
        header.addSubview(label)
        return header
    }
    
    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return (section == 0 || recent.isEmpty) ? 0.0 : 35.0
    }
        
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath)->CGFloat
    {
        if indexPath.section == 0 {
            return 180.0;
        } else {
            l.text = recent[indexPath.row].title
            let expectedSize = l.sizeThatFits(CGSize(width:tableView.bounds.size.width-68, height:1000))
            return expectedSize.height + 34.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}
