//
//  PlaylistDetailView.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/4/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class PlaylistDetailView: UIView
{
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var userNameLbl:UILabel!
    @IBOutlet var createdONDateLbl:UILabel!
    @IBOutlet var createdAtTimeLbl:UILabel!
    
    class func instanceFromNib()->UIView
    {
        return UINib(nibName:"PlaylistDetailView", bundle:nil).instantiate(withOwner: nil, options:nil)[0] as! UIView
    }
}
