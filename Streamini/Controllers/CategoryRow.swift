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
    let site=Config.shared.site()
    var sectionTitle:String?
    let storyboard=UIStoryboard(name:"Main", bundle:nil)
    
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
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier:"videoCell", for:indexPath) as! VideoCell
        
        let stream=oneCategoryItemsArray[indexPath.row] as! Stream
        
        cell.videoTitleLbl?.text=stream.title
        cell.followersCountLbl?.text=stream.user.name
        cell.videoThumbnailImageView?.sd_setImage(with:URL(string:"\(site)/thumb/\(stream.id).jpg"), placeholderImage:UIImage(named:"videostream"))
        
        if sectionTitle=="live"
        {
            let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(liveCellTapped))
            cell.tag=indexPath.row
            cell.addGestureRecognizer(cellRecognizer)
        }
        else
        {
            let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
            cell.tag=indexPath.row
            cell.addGestureRecognizer(cellRecognizer)
        }
        
        return cell
    }
    
    func liveCellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let vc=storyboard.instantiateViewController(withIdentifier:"JoinStreamViewController") as! JoinStreamViewController
        vc.stream=oneCategoryItemsArray[gestureRecognizer.view!.tag] as? Stream
        TBVC.present(vc, animated:true)
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
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
        
        return CGSize(width:220, height:222)
    }
}
