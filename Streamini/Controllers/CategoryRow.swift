//
//  CategoryRow.swift
//  Streamini
//
//  Created by Ankit Garg on 9/8/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class CategoryRow: UITableViewCell
{
    @IBOutlet var collectionView:UICollectionView?
    var oneCategoryItemsArray:NSArray!
    var TBVC:TabBarViewController!
    let (host, _, _, _, _)=Config.shared.wowza()
    var cellIdentifier:String?
    
    func reloadCollectionView()
    {
        collectionView!.reloadData()
    }
    
    func collectionView(_ collectionView:UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return oneCategoryItemsArray.count
    }
    
    func collectionView(_ collectionView:UICollectionView, cellForItemAtIndexPath indexPath:IndexPath)->UICollectionViewCell
    {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier:cellIdentifier!, for:indexPath) as! VideoCell
        
        let stream=oneCategoryItemsArray[indexPath.row] as! Stream
        
        cell.videoTitleLbl?.text=stream.title
        
        if cellIdentifier=="videoCell"
        {
            cell.followersCountLbl?.text=stream.user.name
            cell.videoThumbnailImageView?.sd_setImage(with:URL(string:"http://\(host)/thumb/\(stream.id).jpg"), placeholderImage:UIImage(named:"videostream"))
            
            let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
            cell.tag=indexPath.row
            cell.addGestureRecognizer(cellRecognizer)
        }
        else
        {
            if indexPath.row==0
            {
                cell.videoTitleLbl?.isHidden=true
                cell.followersCountLbl?.isHidden=true
                cell.videoThumbnailImageView?.sd_setImage(with:URL(string:"http://\(host)/thumb/\(stream.id).jpg"), placeholderImage:UIImage(named:"videostream"))
            }
            else
            {
                cell.backgroundColor=UIColor.clear
                cell.followersCountLbl?.text=stream.user.name
            }
        }
        
        return cell
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let modalVC=storyboard.instantiateViewController(withIdentifier:"ModalViewController") as! ModalViewController
        
        let stream=oneCategoryItemsArray[gestureRecognizer.view!.tag] as! Stream
        
        let streamsArray=NSMutableArray()
        streamsArray.add(stream)
        
        modalVC.streamsArray=streamsArray
        modalVC.TBVC=TBVC
        
        TBVC.modalVC=modalVC
        TBVC.configure(stream)
    }
    
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:IndexPath)->CGSize
    {
        let width=(collectionView.frame.size.width-25)/2
        
        if cellIdentifier=="weeklyCell"
        {
            return CGSize(width:width, height:width)
        }
        else
        {
            return CGSize(width:width, height:width+65)
        }
    }
}
