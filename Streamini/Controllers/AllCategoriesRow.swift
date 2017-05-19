//
//  AllCategoriesRow.swift
//  Streamini
//
//  Created by Ankit Garg on 9/10/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class AllCategoriesRow: UITableViewCell
{
    @IBOutlet var collectionView:UICollectionView?
    var sectionItemsArray:NSArray!
    var TBVC:TabBarViewController!
    let (host, _, _, _, _)=Config.shared.wowza()
    
    func reloadCollectionView()
    {
        collectionView!.reloadData()
    }
    
    func collectionView(_ collectionView:UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return sectionItemsArray.count
    }
    
    func collectionView(_ collectionView:UICollectionView, cellForItemAtIndexPath indexPath:IndexPath)->UICollectionViewCell
    {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier:"videoCell", for:indexPath) as! VideoCell
        
        let video=sectionItemsArray[indexPath.row] as! Stream
        
        cell.followersCountLbl?.text=video.user.name
        cell.videoTitleLbl?.text=video.title
        cell.videoThumbnailImageView?.sd_setImage(with:URL(string:"http://\(host)/thumb/\(video.id).jpg"))
        
        let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
        cell.tag=indexPath.row
        cell.addGestureRecognizer(cellRecognizer)
        
        return cell
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let modalVC=storyboard.instantiateViewController(withIdentifier:"ModalViewController") as! ModalViewController
        
        let stream=sectionItemsArray[gestureRecognizer.view!.tag] as! Stream
        
        let streamsArray=NSMutableArray()
        streamsArray.add(stream)
        
        modalVC.streamsArray=streamsArray
        modalVC.TBVC=TBVC
        
        TBVC.modalVC=modalVC
        TBVC.configure(stream)
    }
    
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:IndexPath)->CGSize
    {
        let width=(collectionView.frame.size.width-30)/2
        
        return CGSize(width:width, height:width+65)
    }
}
