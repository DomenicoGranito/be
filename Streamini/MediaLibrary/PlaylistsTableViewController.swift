//
//  PlaylistsTableViewController.swift
//  Music Player
//
//  Created by 岡本拓也 on 2016/01/02.
//  Copyright © 2016年 Sem. All rights reserved.
//

class PlaylistsTableViewController: UITableViewController
{
    override func viewDidLoad()
    {
        
    }
    
    @IBAction func didTapAddButton()
    {
        showTextFieldDialog("Add playlist", message:"", placeHolder:"Name", okButtonTitle:"Add", didTapOkButton:{title in})
    }
    
    override func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 1
    }
    
    override func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier: "playlistCell")! as UITableViewCell
        cell.textLabel?.text="ANKIT"
        
        return cell
    }
    
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath)
    {
        performSegue(withIdentifier: "PlaylistsToPlaylist", sender:nil)
    }
    
    override func tableView(_ tableView:UITableView, commit editingStyle:UITableViewCellEditingStyle, forRowAt indexPath:IndexPath)
    {
        if editingStyle == .delete
        {
            
        }
    }
}
