//
//  PopularStreamCell.swift
//  Streamini
//
//  Created by Ankit Garg on 8/1/18.
//  Copyright © 2018 Cedricm Video. All rights reserved.
//

class PopularStreamCell: UITableViewCell
{
    @IBOutlet var collectionView:UICollectionView!
    
    var streams:NSArray!
    let site=Config.shared.site()
    var streamSelectedDelegate:StreamSelecting!
    
    func reloadCollectionView()
    {
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView:UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return streams.count
    }
    
    func collectionView(_ collectionView:UICollectionView, cellForItemAtIndexPath indexPath:IndexPath)->UICollectionViewCell
    {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier:"videoCell", for:indexPath) as! VideoCell
        
        let video=streams[indexPath.row] as! Stream
        
        cell.categoryNameLbl.text=video.category.uppercased()
        cell.videoTitleLbl.text=video.title.uppercased()
        cell.videoThumbnailImageView.sd_setImage(with:URL(string:"\(site)/thumb/\(video.id).jpg"), placeholderImage:UIImage(named:"videostream"))
        
        let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
        cell.tag=indexPath.row
        cell.addGestureRecognizer(cellRecognizer)
        
        return cell
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        streamSelectedDelegate.streamDidSelected(streams[gestureRecognizer.view!.tag] as! Stream)
    }
    
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:IndexPath)->CGSize
    {
        let width=(collectionView.frame.size.width-30)/2
        
        return CGSize(width:width, height:145)
    }
}
