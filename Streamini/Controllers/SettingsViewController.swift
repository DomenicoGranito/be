//
//  ProfileViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 11/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class SettingsViewController:UITableViewController, UIActionSheetDelegate
{    
    func logout()
    {
        let actionSheet=UIActionSheet.confirmLogoutActionSheet(self)
        actionSheet.show(in:view)
    }
    
    func logoutFailure(error:NSError)
    {
        
    }
    
    func actionSheet(_ actionSheet:UIActionSheet, clickedButtonAt buttonIndex:Int)
    {
        if buttonIndex != actionSheet.cancelButtonIndex
        {
            UserConnector().logout(logoutSuccess, logoutFailure)
        }
    }
    
    func logoutSuccess()
    {
        A0SimpleKeychain().clearAll()
        
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        let navController=appDelegate.window!.rootViewController as! UINavigationController
        navController.popToRootViewController(animated:true)
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
        
        if indexPath.section==2&&indexPath.row==0
        {
            logout()
        }
    }
}
