//
//  AllCategoriesRow.swift
//  Streamini
//
//  Created by Ankit Garg on 9/10/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class AllCategoryRow: UITableViewCell
{
    @IBOutlet var collectionView:UICollectionView?
    var sectionItemsArray:NSArray!
    var navigationControllerReference:UINavigationController?
    
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
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for:indexPath) as! CategoryCell
        
        let category=sectionItemsArray[indexPath.row] as! Category
        
        cell.videoTitleLbl?.text=category.name
        cell.videoThumbnailImageView?.sd_setImage(with:URL(string:"http://spectator.live/thumb/\(category.id).jpg"))
        
        let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
        cell.tag=indexPath.row
        cell.addGestureRecognizer(cellRecognizer)
        
        return cell
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let category=sectionItemsArray[gestureRecognizer.view!.tag] as! Category
        
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewController(withIdentifier:"CategoriesViewController") as! CategoriesViewController
        vc.categoryName=category.name
        vc.categoryID=Int(category.id)
        navigationControllerReference?.pushViewController(vc, animated:true)
    }
    
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:IndexPath)->CGSize
    {
        let width=(collectionView.frame.size.width-30)/2
        
        return CGSize(width:width, height:width)
    }
}
