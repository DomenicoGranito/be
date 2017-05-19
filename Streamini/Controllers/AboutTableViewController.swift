//
//  AboutTableViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 5/12/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class AboutTableViewController: UITableViewController
{
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath)
    {
        tableView.deselectRow(at:indexPath, animated:true)
        
        if indexPath.section==2
        {
            performSegue(withIdentifier:"Legal", sender:indexPath)
        }
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender:Any?)
    {
        if segue.identifier=="Legal"
        {
            let controller=segue.destination as! LegalViewController
            let index=(sender as! IndexPath).row
            controller.type=LegalViewControllerType(rawValue:index)!
        }
    }
}
