//
//  LinkedUserCellTableViewCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 07/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

protocol LinkedUserCellDelegate:class
{
    func willStatusChanged(_ cell:UITableViewCell)
}

class LinkedUserCell: UITableViewCell
{
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var usernameLabel:UILabel!
    @IBOutlet var likesLbl:UILabel!
    @IBOutlet var userStatusButton:SensibleButton!
    @IBOutlet var unblockButton:UIButton!
    
    var delegate:LinkedUserCellDelegate?
    var blockedView=false
    
    var isStatusOn=false
        {
        didSet
        {
            let image=isStatusOn ? UIImage(named:"checkmark") : UIImage(named:"plus")
            
            userStatusButton.setImage(image, for:.normal)
        }
    }
    
    func update(_ user:User)
    {
        likesLbl.text="\(user.followers) FOLLOWERS - \(user.desc)"
        usernameLabel.text=user.name
        userImageView.sd_setImage(with:user.avatarURL(), placeholderImage:UIImage(named:"profile"))
        
        userStatusButton.isHidden=UserContainer.shared.logged().id==user.id
        unblockButton.isHidden=UserContainer.shared.logged().id==user.id
        
        if blockedView
        {
            userStatusButton.isHidden=true
            unblockButton.addTarget(self, action:#selector(statusButtonPressed), for:.touchUpInside)
        }
        else
        {
            unblockButton.isHidden=true
            isStatusOn=user.isFollowed
            userStatusButton.addTarget(self, action:#selector(statusButtonPressed), for:.touchUpInside)
        }
    }
    
    func updateRecent(_ recent:Stream, isMyStream:Bool = false)
    {
        if isMyStream
        {
            self.textLabel!.text = recent.title
        }
        else
        {
            usernameLabel.text      = recent.title
            userImageView.image     = UIImage(named:"play")
            userImageView.tintColor = UIColor.navigationBarColor()
            userStatusButton.isHidden = true
        }
    }
    
    func statusButtonPressed()
    {
        if let del=delegate
        {
            del.willStatusChanged(self)
        }
    }
}
