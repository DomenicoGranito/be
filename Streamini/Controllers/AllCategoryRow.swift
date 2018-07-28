//
//  AllCategoriesRow.swift
//  Streamini
//
//  Created by Ankit Garg on 9/10/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class AllCategoryRow: UITableViewCell
{
    @IBOutlet var collectionView:UICollectionView!
    
    var sectionItemsArray:NSArray!
    var navigationControllerReference:UINavigationController!
    let site=Config.shared.site()
    
    func reloadCollectionView()
    {
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView:UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return sectionItemsArray.count
    }
    
    func collectionView(_ collectionView:UICollectionView, cellForItemAtIndexPath indexPath:IndexPath)->UICollectionViewCell
    {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier:"categoryCell", for:indexPath) as! CategoryCell
        
        let category=sectionItemsArray[indexPath.row] as! Category
        
        cell.videoTitleLbl.text=category.name.uppercased()
        cell.videoTitleLbl.addCharacterSpacing()
        
        if category.isChannel
        {
            cell.videoThumbnailImageView.sd_setImage(with:URL(string:"\(site)/media/channels/\(category.id).jpg"))
        }
        else
        {
            cell.videoThumbnailImageView.sd_setImage(with:URL(string:"\(site)/media/sub-categories/\(category.id).jpg"))
        }
        
        let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
        cell.tag=indexPath.row
        cell.addGestureRecognizer(cellRecognizer)
        
        return cell
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let category=sectionItemsArray[gestureRecognizer.view!.tag] as! Category
        
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        
        if category.isChannel
        {
            let vc=storyboard.instantiateViewController(withIdentifier:"ChannelsViewController") as! ChannelsViewController
            
            vc.channelName=category.name
            vc.channelID=category.id
            
            navigationControllerReference.pushViewController(vc, animated:true)
        }
        else
        {
            let vc=storyboard.instantiateViewController(withIdentifier:"CategoriesViewController") as! CategoriesViewController
            
            vc.categoryName=category.name
            vc.categoryID=category.id
            vc.isSubCategory=true
            
            navigationControllerReference.pushViewController(vc, animated:true)
        }
    }
    
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:IndexPath)->CGSize
    {
        let width=(collectionView.frame.size.width-6)/2
        
        return CGSize(width:width, height:width)
    }
}

extension UILabel
{
    func addCharacterSpacing()
    {
        if let labelText=text, labelText.count>0
        {
            let attributedString=NSMutableAttributedString(string:labelText)
            attributedString.addAttribute(NSKernAttributeName, value:1.15, range:NSRange(location:0, length:attributedString.length-1))
            attributedText=attributedString
        }
    }
}
