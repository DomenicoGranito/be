//
//  UserViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 30/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

protocol UserSelecting:class
{
    func userDidSelected(_ user:User)
}

protocol StreamSelecting:class
{
    func streamDidSelected(_ stream:Stream)
    func openPopUpForSelectedStream(_ stream:Stream)
}

protocol UserStatisticsDelegate:class
{
    func recentStreamsDidSelected(_ userId:UInt)
    func followersDidSelected(_ userId:UInt)
    func followingDidSelected(_ userId:UInt)
}

protocol UserStatusDelegate:class
{
    func followStatusDidChange(_ status:Bool, user:User)
    func blockStatusDidChange(_ status:Bool, user:User)
}

class UserViewController: BaseViewController, ProfileDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AmazonToolDelegate, UserSelecting, StreamSelecting
{
    @IBOutlet var tableView:UITableView!
    @IBOutlet var emptyLabel:UILabel!
    @IBOutlet var backgroundImageView:UIImageView?
    @IBOutlet var changeAvatarButton:UIButton?
    @IBOutlet var userHeaderView:UserHeaderView!
    @IBOutlet var recentCountLabel:UILabel!
    @IBOutlet var recentLabel:UILabel!
    @IBOutlet var followersCountLabel:UILabel!
    @IBOutlet var followersLabel:UILabel!
    @IBOutlet var followingCountLabel:UILabel!
    @IBOutlet var followingLabel:UILabel!
    @IBOutlet var followButton:UIButton!
    @IBOutlet var activityIndicator:UIActivityIndicatorView!
    @IBOutlet var headerView:GSKStretchyHeaderView!
    @IBOutlet var backButtonImageView:UIImageView!
    @IBOutlet var backButton:UIButton!
    
    var user:User?
    var userStatusDelegate:UserStatusDelegate?
    var userSelectedDelegate:UserSelecting?
    var selectedImage:UIImage?
    var profileDelegate:ProfileDelegate?
    var dataSource:UserStatisticsDataSource?
    var TBVC:TabBarViewController!
    
    override func viewDidLoad()
    {
        if view.frame.size.height>667
        {
            headerView.minimumContentHeight=140
            backButtonImageView.frame=CGRect(x:15, y:54, width:13, height:24)
            backButton.frame=CGRect(x:0, y:0, width:100, height:88)
        }
        
        TBVC=tabBarController as! TabBarViewController
        
        let WeChatLogin=A0SimpleKeychain().string(forKey:"WeChatLogin")
        
        if UserContainer.shared.logged().id==user!.id&&WeChatLogin=="0"
        {
            changeAvatarButton?.isEnabled=true
        }
        
        configureView()
        
        update(user!.id)
        
        recentButtonPressed()
        
        navigationController?.isNavigationBarHidden=true
        
        tableView.addSubview(headerView)
    }
    
    @IBAction func avatarButtonPressed()
    {
        let actionSheet=UIActionSheet.changeUserpicActionSheet(self)
        actionSheet.show(in:view)
    }

    func actionSheet(_ actionSheet:UIActionSheet, clickedButtonAt buttonIndex:Int)
    {
        let controller=UIImagePickerController()
        controller.allowsEditing=true
        controller.delegate=self
        
        if buttonIndex==1
        {
            controller.sourceType = .photoLibrary
            self.present(controller, animated:true)
        }
        if buttonIndex==2
        {
            controller.sourceType = .camera
            self.present(controller, animated:true)
        }
    }

    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingImage image:UIImage!, editingInfo:[AnyHashable:Any]!)
    {
        picker.dismiss(animated:true, completion:{()->() in
            
                self.selectedImage=image.fixOrientation().imageScaledToFitToSize(CGSize(width:100, height:100))
                self.uploadImage(self.selectedImage!)
        })
    }

    func uploadImage(_ image:UIImage)
    {
        let filename="\(UserContainer.shared.logged().id)-avatar.jpg"
        
        if AmazonTool.isAmazonSupported()
        {
            AmazonTool.shared.uploadImage(image, name:filename)
            {(bytesSent, totalBytesSent, totalBytesExpectedToSend)->Void in
                DispatchQueue.main.sync(execute: {()->Void in
                                let progress: Float=Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                                self.userHeaderView.progressView.setProgress(progress, animated:true)
                })
            }
        }
        else
        {
            let data=UIImageJPEGRepresentation(image, 1.0)!
            UserConnector().uploadAvatar(filename, data, uploadAvatarSuccess, uploadAvatarFailure, {(bytesSent, totalBytesSent, totalBytesExpectedToSend)->Void in
                    //let progress: Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                    //self.userHeaderView.progressView.setProgress(progress, animated: true)
            })
        }
    }

    func uploadAvatarSuccess()
    {
        //userHeaderView.progressView.setProgress(0.0, animated:false)
        userHeaderView.updateAvatar(user!, placeholder:selectedImage!)
        if let delegate=profileDelegate
        {
            delegate.reload()
        }
    }
    
    func uploadAvatarFailure(error:NSError)
    {
        handleError(error)
    }
    
    func imageDidUpload()
    {
        UserConnector().avatar(uploadAvatarSuccess, uploadAvatarFailure)
    }

    func imageUploadFailed(_ error:NSError)
    {
        handleError(error)
    }

    func configureView()
    {
        let recentLabelText=NSLocalizedString("user_card_recent", comment:"")
        recentLabel.text=recentLabelText
        
        let followersLabelText=NSLocalizedString("user_card_followers", comment:"")
        followersLabel.text=followersLabelText
        
        let followingLabelText=NSLocalizedString("user_card_following", comment:"")
        followingLabel.text=followingLabelText
        
        followButton.isHidden=UserContainer.shared.logged().id==user!.id
        
        emptyLabel.text=NSLocalizedString("table_no_data", comment:"")
        
        //        tableView.showsPullToRefresh=true
        //        tableView.showsInfiniteScrolling=true
        
        //        tableView.addPullToRefresh
        //            {()->() in
        //                self.dataSource!.reload()
        //        }
        //
        //        tableView.addInfiniteScrolling
        //            {()->() in
        //                self.dataSource!.fetchMore()
        //        }
    }
    
    @IBAction func recentButtonPressed()
    {
        dataSource=RecentStreamsDataSource(user!.id, tableView)
        dataSource!.streamSelectedDelegate=self
        helper()
    }
    
    @IBAction func followersButtonPressed()
    {
        dataSource=FollowersDataSource(user!.id, tableView)
        dataSource!.userSelectedDelegate=self
        helper()
    }
    
    @IBAction func followingButtonPressed()
    {
        dataSource=FollowingDataSource(user!.id, tableView)
        dataSource!.userSelectedDelegate=self
        helper()
    }
    
    func helper()
    {
        dataSource!.profileDelegate=self
        dataSource!.clean()
        dataSource!.reload()
    }
    
    @IBAction func followButtonPressed()
    {
        followButton.isEnabled=false
        
        if user!.isFollowed
        {
            SocialConnector().unfollow(user!.id, unfollowSuccess, unfollowFailure)
        }
        else
        {
            SocialConnector().follow(user!.id, followSuccess, followFailure)
        }
    }
    
    func reload()
    {
        update(user!.id)
    }
    
    func followSuccess()
    {
        followButton.isEnabled=true
        user!.isFollowed=true
        
        followButton.layer.borderColor=UIColor(red:190/255, green:142/255, blue:64/255, alpha:1).cgColor
        followButton.setTitle("FOLLOWING", for:.normal)
        
        if let delegate=userStatusDelegate
        {
            delegate.followStatusDidChange(true, user:user!)
        }
        
        update(user!.id)
    }
    
    func followFailure(_ error:NSError)
    {
        handleError(error)
        followButton.isEnabled=true
    }
    
    func unfollowSuccess()
    {
        followButton.isEnabled=true
        user!.isFollowed=false
        
        followButton.layer.borderColor=UIColor.darkGray.cgColor
        followButton.setTitle("FOLLOW", for:.normal)
        
        if let delegate=userStatusDelegate
        {
            delegate.followStatusDidChange(false, user:user!)
        }
        
        update(user!.id)
    }
    
    func unfollowFailure(_ error:NSError)
    {
        handleError(error)
        followButton.isEnabled=true
    }
    
    func getUserSuccess(_ user:User)
    {
        self.user=user
        
        userHeaderView.update(user)
        recentCountLabel.text="\(user.recent)"
        followersCountLabel.text="\(user.followers)"
        followingCountLabel.text="\(user.following)"
        
        if user.isFollowed
        {
            followButton.layer.borderColor=UIColor(red:190/255, green:142/255, blue:64/255, alpha:1).cgColor
            followButton.setTitle("FOLLOWING", for:.normal)
        }
        else
        {
            followButton.layer.borderColor=UIColor.darkGray.cgColor
            followButton.setTitle("FOLLOW", for:.normal)
        }
        
        backgroundImageView?.image=renderImageFromView()
        activityIndicator.stopAnimating()
    }
    
    func getUserFailure(_ error:NSError)
    {
        handleError(error)
        activityIndicator.stopAnimating()
    }
    
    func update(_ userId:UInt)
    {
        activityIndicator.startAnimating()
        UserConnector().get(userId, getUserSuccess, getUserFailure)
    }
    
    @IBAction func back()
    {
        navigationController!.popViewController(animated:true)
    }
    
    func renderImageFromView()->UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(userHeaderView.frame.size, true, 0)
        let context=UIGraphicsGetCurrentContext()
        
        userHeaderView.layer.render(in:context!)
        
        let renderedImage=UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return renderedImage
    }
    
    func streamDidSelected(_ stream:Stream)
    {
        let modalVC=storyBoard.instantiateViewController(withIdentifier: "ModalViewController") as! ModalViewController
        
        let streamsArray=NSMutableArray()
        streamsArray.add(stream)
        
        modalVC.streamsArray=streamsArray
        modalVC.TBVC=TBVC
        
        TBVC.modalVC=modalVC
        TBVC.configure(stream)
    }
    
    func openPopUpForSelectedStream(_ stream:Stream)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"PopUpViewController") as! PopUpViewController
        vc.stream=stream
        present(vc, animated:true)
    }
    
    func userDidSelected(_ user:User)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier: "UserViewControllerId") as! UserViewController
        vc.user=user
        navigationController?.pushViewController(vc, animated:true)
    }
}
