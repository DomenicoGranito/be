//
//  PlaylistView.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/4/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class PlaylistView: UIView
{
    @IBOutlet var playlistThumbnailImageView:UIImageView!
    @IBOutlet var playlistNameLbl:UILabel!
    @IBOutlet var followButton:UIButton!
    @IBOutlet var playlistFollowersLbl:UILabel!
    
    class func instanceFromNib()->UIView
    {
        return UINib(nibName:"PlaylistView", bundle:nil).instantiate(withOwner: nil, options:nil)[0] as! UIView
    }
}
