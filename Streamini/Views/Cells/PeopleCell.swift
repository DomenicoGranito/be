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
    //@IBOutlet var likesIcon:UIImageView!
    @IBOutlet var descriptionLabel:UILabel!
    //@IBOutlet var userStatusButton:SensibleButton!
    //weak var delegate:LinkedUserCellDelegate?
    var user:User?
    
//    var isStatusOn = false {
//        didSet {
//            let image: UIImage?
//            if isStatusOn {
//                image = UIImage(named: "checkmark")
//            } else {
//                image = UIImage(named: "plus")
//            }
//            userStatusButton.setImage(image!, for:.normal)
//        }
//    }
    
    func update(_ user:User)
    {
        self.user=user
        
        userImageView.sd_setImage(with:user.avatarURL(), placeholderImage:UIImage(named:"profile"))
        
        usernameLabel.text      = user.name
        likesLabel.text         = "\(user.likes)"
        descriptionLabel.text   = user.desc
        
        //userStatusButton.isHidden=(UserContainer.shared.logged().id==user.id)
        //isStatusOn=user.isFollowed
        //userStatusButton.addTarget(self, action:#selector(statusButtonPressed), for:.touchUpInside)
    }
    
//    func statusButtonPressed()
//    {
//        if let del=delegate
//        {
//            del.willStatusChanged(self)
//        }
//    }
}
