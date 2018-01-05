//
//  PlayerViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 1/4/18.
//  Copyright © 2018 Cedricm Video. All rights reserved.
//

class PlayerViewController: UIViewController
{
    @IBOutlet var videoProgressDurationLbl:UILabel!
    @IBOutlet var videoDurationLbl:UILabel!
    @IBOutlet var seekBar:UISlider!
    @IBOutlet var playButton:UIButton!
    @IBOutlet var relatedVideosTbl:UITableView!
    
    var TBVC:TabBarViewController!
    var player:DWMoviePlayerController!
    var stream:Stream!
    
    override func viewDidLoad()
    {
        
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 1
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"AboutVideoCell") as! AboutVideoCell
        
        return cell
    }
}
