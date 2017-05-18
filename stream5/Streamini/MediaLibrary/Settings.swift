//
//  VidQualityvc.swift
//  Music Player
//
//  Created by Sem on 7/3/15.
//  Copyright (c) 2015 Sem. All rights reserved.
//

import CoreData

class Settings: UITableViewController {
    
    var context : NSManagedObjectContext!
    var settings : NSManagedObject!
    
    func selectRow(_ path : IndexPath){
        tableView.selectRow(at: path, animated: false, scrollPosition: UITableViewScrollPosition.none)
        tableView.cellForRow(at: path)?.accessoryType = UITableViewCellAccessoryType.checkmark
    }
    
    func deselectRow(_ path : IndexPath){
        tableView.deselectRow(at: path, animated: false)
        tableView.cellForRow(at: path)?.accessoryType = UITableViewCellAccessoryType.none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 44
        
        let appDel = UIApplication.shared.delegate as? AppDelegate
        context = appDel!.managedObjectContext
        
        //retrieve settings, or initialize default settings if unset
        settings = MiscFuncs.getSettings()
        let qualRow = IndexPath(row: settings.value(forKey: "quality") as! Int, section: 0)
        deselectRow(qualRow)
        selectRow(qualRow)
        
        let cacheRow = IndexPath(row: settings.value(forKey: "cache") as! Int, section: 1)
        deselectRow(cacheRow)
        selectRow(cacheRow)
        
        //set background
       // tableView.backgroundColor = UIColor.clearColor()
        //let imgView = UIImageView(image: UIImage(named: "pastel.jpg"))
       // imgView.frame = tableView.frame
        //tableView.backgroundView = imgView
    }
        
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.clear
        header.backgroundView?.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView:UITableView, willSelectRowAt indexPath:IndexPath)->IndexPath?
    {
        if let selectedRows = tableView.indexPathsForSelectedRows as [IndexPath]?
        {
            for selectedIndexPath : IndexPath in selectedRows
            {
                if selectedIndexPath.section == indexPath.section
                {
                    tableView.deselectRow(at:selectedIndexPath, animated:false)
                    tableView.cellForRow(at:selectedIndexPath)?.accessoryType = .none
                }
            }
        }
        return indexPath
    }
    
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath)
    {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        switch (indexPath as NSIndexPath).section {
        case 0: //Video Quality
            settings.setValue((indexPath as NSIndexPath).row, forKey: "quality")
        case 1://Video Caching
            settings.setValue((indexPath as NSIndexPath).row, forKey: "cache")
        default:
            break
        }
        
        do {
            try context.save()
        } catch _ {
        }
    }
    
   override func tableView(_ tableView:UITableView, willDeselectRowAt indexPath:IndexPath)->IndexPath?
   {
        return nil
    }
}
