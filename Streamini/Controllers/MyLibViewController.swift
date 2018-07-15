//
//  MyLibViewController.swift
//  BEINIT
//
//  Created by Dominic Granito on 4/2/2017.
//  Copyright © 2017 UniProgy s.r.o. All rights reserved.
//

class RecentlyPlayedCell:UITableViewCell
{
    @IBOutlet var videoTitleLbl:UILabel!
    @IBOutlet var artistNameLbl:UILabel!
    @IBOutlet var videoThumbnailImageView:UIImageView!
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var likesAndCommentsCountLbl:UILabel!
    @IBOutlet var shareButton:UIButton!
    @IBOutlet var likeButton:UIButton!
    
    var stream:Stream!
    
    @IBAction func like()
    {
        let words=likesAndCommentsCountLbl.text!.components(separatedBy:" ")
        
        if SongManager.isAlreadyFavourited(stream.id)
        {
            likesAndCommentsCountLbl.text="\(Int(words[0])!-1) Likes • \(stream.comments) Comments"
            likeButton.setImage(UIImage(named:"heart-small"), for:.normal)
            SongManager.removeFromFavourite(stream.id)
        }
        else
        {
            likesAndCommentsCountLbl.text="\(Int(words[0])!+1) Likes • \(stream.comments) Comments"
            likeButton.setImage(UIImage(named:"red_heart"), for:.normal)
            SongManager.addToFavourite(stream.title, stream.streamHash, stream.id, stream.user.name, stream.vType, stream.videoID, stream.user.id)
        }
    }
    
    func songLikeStatus()
    {
        if SongManager.isAlreadyFavourited(stream.id)
        {
            likeButton.setImage(UIImage(named:"red_heart"), for:.normal)
        }
        else
        {
            likeButton.setImage(UIImage(named:"heart-small"), for:.normal)
        }
    }
}

class EditCell:UITableViewCell
{
    @IBOutlet var editButton:UIButton!
}

class MyLibViewController: BaseViewController
{
    @IBOutlet var messageLbl:UILabel!
    @IBOutlet var itemsTbl:UITableView!
    
    let menuItemTitlesArray=["Live Streams", "Videos", "Channels"]
    let menuItemIconsArray=["rec-off", "youtube", "videochannel"]
    
    var recentlyPlayed:[NSManagedObject]!
    var TBVC:TabBarViewController!
    let site=Config.shared.site()
        
    override func viewWillAppear(_ animated:Bool)
    {
        TBVC=tabBarController as! TabBarViewController
        
        navigationController?.isNavigationBarHidden=false
        
        recentlyPlayed=SongManager.getRecentlyPlayed()
        
        messageLbl.isHidden=recentlyPlayed.count==0 ? false : true
        
        itemsTbl.reloadData()
    }
    
    @IBAction func myaccount()
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"UserViewControllerId") as! UserViewController
        vc.user=UserContainer.shared.logged()
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func tableView(_ tableView:UITableView, heightForRowAtIndexPath indexPath:IndexPath)->CGFloat
    {
        if indexPath.row<3
        {
            return 44
        }
        else if indexPath.row==3
        {
            return 60
        }
        else
        {
            return 80
        }
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return recentlyPlayed.count+4
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        if indexPath.row<3
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"MenuCell") as! MenuCell
            
            cell.menuItemTitleLbl.text=menuItemTitlesArray[indexPath.row]
            cell.menuItemIconImageView.image=UIImage(named:menuItemIconsArray[indexPath.row])
            
            cell.selectedBackgroundView=SelectedCellView().create()
            
            return cell
        }
        else if indexPath.row==3
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"EditCell") as! EditCell
            
            cell.editButton.isHidden=recentlyPlayed.count==0 ? true : false
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"RecentlyPlayedCell") as! RecentlyPlayedCell
            
            cell.videoTitleLbl.text=recentlyPlayed[indexPath.row-4].value(forKey:"streamTitle") as? String
            cell.artistNameLbl.text=recentlyPlayed[indexPath.row-4].value(forKey:"streamUserName") as? String
            cell.videoThumbnailImageView.sd_setImage(with:URL(string:"\(site)/thumb/\(recentlyPlayed[indexPath.row-4].value(forKey:"streamID") as! Int).jpg"), placeholderImage:UIImage(named:"stream"))
            
            cell.selectedBackgroundView=SelectedCellView().create()
            
            return cell
        }
    }
    
    func tableView(_ tableView:UITableView, canEditRowAtIndexPath indexPath:IndexPath)->Bool
    {
        return indexPath.row<4 ? false : true
    }
    
    func tableView(_ tableView:UITableView, editActionsForRowAtIndexPath indexPath:IndexPath)->[UITableViewRowAction]?
    {
        let clearButton=UITableViewRowAction(style:.default, title:"Clear")
        {action, indexPath in
            
            SongManager.deleteRecentlyPlayed(self.recentlyPlayed[indexPath.row-4])
            self.recentlyPlayed.remove(at:indexPath.row-4)
            tableView.deleteRows(at:[indexPath], with:.automatic)
            
            if self.recentlyPlayed.count==0
            {
                let editCellIndexPath=IndexPath(row:3, section:0)
                let editCell=tableView.cellForRow(at:editCellIndexPath) as! EditCell
                tableView.isEditing=false
                editCell.editButton.setTitle("Edit", for:.normal)
                editCell.editButton.isHidden=true
                self.messageLbl.isHidden=false
            }
        }
        clearButton.backgroundColor=UIColor.darkGray
        
        return [clearButton]
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAtIndexPath indexPath:IndexPath)
    {
        if indexPath.row>3
        {
            let playerVC=storyBoard.instantiateViewController(withIdentifier:"PlayerViewController") as! PlayerViewController
            
            playerVC.stream=makeStreamClassObject(indexPath.row-4)
            playerVC.TBVC=TBVC
            
            TBVC.playerVC=playerVC
            TBVC.configure(makeStreamClassObject(indexPath.row-4))
        }
        else if indexPath.row<3
        {
            if indexPath.row==1||indexPath.row==0
            {
                performSegue(withIdentifier:"Videos", sender:indexPath)
            }
            if indexPath.row==2
            {
                performSegue(withIdentifier:"Channels", sender:nil)
            }
        }
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender:Any?)
    {
        if segue.identifier=="Videos"
        {
            let controller=segue.destination as! VideosTableViewController
            controller.vType=(sender as! IndexPath).row
        }
    }
    
    @IBAction func editButtonPressed(_ sender:UIButton)
    {
        if itemsTbl!.isEditing
        {
            sender.setTitle("Edit", for:.normal)
            itemsTbl.setEditing(false, animated:true)
        }
        else
        {
            sender.setTitle("Done", for:.normal)
            itemsTbl.setEditing(true, animated:true)
        }
    }
    
    func makeStreamClassObject(_ row:Int)->Stream
    {
        let user=User()
        
        user.name=recentlyPlayed[row].value(forKey:"streamUserName") as! String
        user.id=recentlyPlayed[row].value(forKey:"streamUserID") as! Int
        
        let stream=Stream()
        
        stream.id=recentlyPlayed[row].value(forKey:"streamID") as! Int
        stream.title=recentlyPlayed[row].value(forKey:"streamTitle") as! String
        stream.streamHash=recentlyPlayed[row].value(forKey:"streamHash") as! String
        stream.videoID=recentlyPlayed[row].value(forKey:"streamKey") as! String
        
        stream.user=user
        
        return stream
    }
}
