//
//  CategoryRow.swift
//  Streamini
//
//  Created by Ankit Garg on 9/8/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class CategoryRow: UITableViewCell
{
    @IBOutlet var collectionView:UICollectionView!
    
    var oneCategoryItemsArray:NSArray!
    var TBVC:TabBarViewController!
    let site=Config.shared.site()
    var categoryName:String!
    var categoryID:Int!
    let storyboard=UIStoryboard(name:"Main", bundle:nil)
    var navigationControllerReference:UINavigationController!
    var homeClassReference:HomeViewController!
    
    func reloadCollectionView()
    {
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView:UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return oneCategoryItemsArray.count+1
    }
    
    func collectionView(_ collectionView:UICollectionView, cellForItemAtIndexPath indexPath:IndexPath)->UICollectionViewCell
    {
        if indexPath.row==oneCategoryItemsArray.count
        {
            let cell=collectionView.dequeueReusableCell(withReuseIdentifier:"seeMoreVideosCell", for:indexPath)
            
            let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(seeMoreVideosTapped))
            cell.addGestureRecognizer(cellRecognizer)
            
            return cell
        }
        
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier:"videoCell", for:indexPath) as! VideoCell
        
        let stream=oneCategoryItemsArray[indexPath.row] as! Stream
        
        cell.videoTitleLbl.text=stream.title
        cell.followersCountLbl.text=stream.user.name
        cell.videoThumbnailImageView.sd_setImage(with:URL(string:"\(site)/thumb/\(stream.id).jpg"), placeholderImage:UIImage(named:"videostream"))
        
        if categoryName=="live"
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
    
    func seeMoreVideosTapped()
    {
        let vc=storyboard.instantiateViewController(withIdentifier:"CategoriesViewController") as! CategoriesViewController
        vc.categoryName=categoryName
        vc.categoryID=categoryID
        navigationControllerReference.pushViewController(vc, animated:true)
    }
    
    func liveCellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let vc=storyboard.instantiateViewController(withIdentifier:"JoinStreamViewController") as! JoinStreamViewController
        vc.stream=oneCategoryItemsArray[gestureRecognizer.view!.tag] as? Stream
        TBVC.present(vc, animated:true)
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let playerVC=storyboard.instantiateViewController(withIdentifier:"PlayerViewController") as! PlayerViewController
        
        let stream=oneCategoryItemsArray[gestureRecognizer.view!.tag] as! Stream
        
        playerVC.stream=stream
        playerVC.TBVC=TBVC
        playerVC.homeClassReference=homeClassReference
        
        TBVC.playerVC=playerVC
        TBVC.configure(stream)
    }
}
