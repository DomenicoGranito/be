//
//  PeopleCellTableViewCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 10/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class PeopleCell: UITableViewCell
{
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var usernameLabel:UILabel!
    @IBOutlet var likesLabel:UILabel!
    var user:User?
    
    func update(_ user:User)
    {
        self.user=user
        
        userImageView.sd_setImage(with:user.avatarURL(), placeholderImage:UIImage(named:"profile"))
        usernameLabel.text=user.name
        likesLabel.text="\(user.followers) FOLLOWERS - \(user.desc)"
    }
}
