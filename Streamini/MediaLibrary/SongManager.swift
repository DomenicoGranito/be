//
//  SongManager.swift
//  Music Player
//
//  Created by Samuel Chu on 2/19/16.
//  Copyright © 2016 Sem. All rights reserved.
//

import Foundation
import CoreData

open class SongManager
{
    static var context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext!
    static var documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    class func getSong(_ identifier:String)->NSManagedObject
    {
        let songRequest:NSFetchRequest<NSFetchRequestResult>=NSFetchRequest(entityName:"Song")
        songRequest.predicate=NSPredicate(format:"identifier=%@", identifier)
        let fetchedSongs=try! context.fetch(songRequest) as NSArray
        return fetchedSongs[0] as! NSManagedObject
    }
    
    class func getRecentlyPlayed()->[NSManagedObject]
    {
        let recentlyPlayedRequest:NSFetchRequest<NSFetchRequestResult>=NSFetchRequest(entityName:"RecentlyPlayed")
        let fetchedSongs=try! context.fetch(recentlyPlayedRequest)
        
        let sortedArray=NSMutableArray()
        
        for i in stride(from:fetchedSongs.count-1, through:0, by:-1)
        {
            sortedArray.add(fetchedSongs[i])
        }
        
        return (sortedArray as NSArray) as! [NSManagedObject]
    }
    
    class func getSearchHistory()->[NSManagedObject]
    {
        let searchHistoryRequest:NSFetchRequest<NSFetchRequestResult>=NSFetchRequest(entityName:"SearchHistory")
        return try! context.fetch(searchHistoryRequest) as! [NSManagedObject]
    }
    
    class func addToSearchHistory(_ title:String)
    {
        let newSearchHistory=NSEntityDescription.insertNewObject(forEntityName: "SearchHistory", into:context)
        newSearchHistory.setValue(title, forKey:"title")
        save()
    }
    
    class func deleteSearchHistory()
    {
        let searchHistoryEntity:NSFetchRequest<NSFetchRequestResult>=NSFetchRequest(entityName:"SearchHistory")
        let fetchedSearchHistory=try! context.fetch(searchHistoryEntity)
        
        for i in 0 ..< fetchedSearchHistory.count
        {
            context.delete(fetchedSearchHistory[i] as! NSManagedObject)
        }
        
        save()
    }

    class func getPlaylist(_ playlistName:String)->NSManagedObject
    {
        let playlistRequest:NSFetchRequest<NSFetchRequestResult>=NSFetchRequest(entityName:"Playlist")
        playlistRequest.predicate = NSPredicate(format: "playlistName = %@", playlistName)
        let fetchedPlaylists:NSArray=try! context.fetch(playlistRequest) as NSArray
        return fetchedPlaylists[0] as! NSManagedObject
    }
    
    class func isPlaylist(_ playlistName:String)->Bool
    {
        let playlistRequest:NSFetchRequest<NSFetchRequestResult>=NSFetchRequest(entityName:"Playlist")
        playlistRequest.predicate = NSPredicate(format: "playlistName = %@", playlistName)
        let fetchedPlaylists=try! context.fetch(playlistRequest) as NSArray
        if(fetchedPlaylists.count > 0) {
            return true
        }
        return false
    }
    
    class func deleteBlockedUserVideos(_ userID:UInt)
    {
        let favouriteEntity:NSFetchRequest<NSFetchRequestResult>=NSFetchRequest(entityName:"Favourites")
        favouriteEntity.predicate=NSPredicate(format:"streamUserID=%d", userID)
        let fetchedFavourites=try! context.fetch(favouriteEntity)
        
        for i in 0 ..< fetchedFavourites.count
        {
            context.delete(fetchedFavourites[i] as! NSManagedObject)
        }
        
        let recentlyPlayedEntity:NSFetchRequest<NSFetchRequestResult>=NSFetchRequest(entityName:"RecentlyPlayed")
        recentlyPlayedEntity.predicate=NSPredicate(format:"streamUserID=%d", userID)
        let fetchedRecentlyPlayed=try! context.fetch(recentlyPlayedEntity)
        
        for i in 0 ..< fetchedRecentlyPlayed.count
        {
            context.delete(fetchedRecentlyPlayed[i] as! NSManagedObject)
        }
        
        save()
    }
    
    class func isRecentlyPlayed(_ streamID:UInt)->Bool
    {
        let recentlyPlayedEntity:NSFetchRequest<NSFetchRequestResult>=NSFetchRequest(entityName:"RecentlyPlayed")
        recentlyPlayedEntity.predicate=NSPredicate(format:"streamID=%d", streamID)
        let fetchedRecentlyPlayed=try! context.fetch(recentlyPlayedEntity)
        
        if(fetchedRecentlyPlayed.count>0)
        {
            return true
        }
        
        return false
    }
    
    class func addToRecentlyPlayed(_ streamTitle:String, _ streamHash:String, _ streamID:UInt, _ streamUserName:String, _ streamKey:String, _ streamUserID:UInt)
    {
        if(!isRecentlyPlayed(streamID))
        {
            let newRecentlyPlayed=NSEntityDescription.insertNewObject(forEntityName: "RecentlyPlayed", into:context)
            newRecentlyPlayed.setValue(streamTitle, forKey:"streamTitle")
            newRecentlyPlayed.setValue(streamHash, forKey:"streamHash")
            newRecentlyPlayed.setValue(streamUserName, forKey:"streamUserName")
            newRecentlyPlayed.setValue(streamID, forKey:"streamID")
            newRecentlyPlayed.setValue(streamKey, forKey:"streamKey")
            newRecentlyPlayed.setValue(streamUserID, forKey:"streamUserID")
            save()
            
            if(getRecentlyPlayed().count>25)
            {
                let objectToBeDelete=getRecentlyPlayed().first
                
                deleteRecentlyPlayed(objectToBeDelete!)
            }
        }
    }
    
    class func deleteRecentlyPlayed(_ objectToBeDelete:NSManagedObject)
    {
        context.delete(objectToBeDelete)
        save()
    }
    
    class func addToFavourite(_ streamTitle:String, _ streamHash:String, _ streamID:UInt, _ streamUserName:String, _ vType:Int, _ streamKey:String, _ streamUserID:UInt)
    {
        let newFavourite=NSEntityDescription.insertNewObject(forEntityName: "Favourites", into:context)
        newFavourite.setValue(streamTitle, forKey:"streamTitle")
        newFavourite.setValue(streamHash, forKey:"streamHash")
        newFavourite.setValue(streamUserName, forKey:"streamUserName")
        newFavourite.setValue(streamID, forKey:"streamID")
        newFavourite.setValue(streamKey, forKey:"streamKey")
        newFavourite.setValue(vType, forKey:"vType")
        newFavourite.setValue(streamUserID, forKey:"streamUserID")
        save()
    }
    
    class func removeFromFavourite(_ streamID:UInt)
    {
        let favouriteEntity:NSFetchRequest<NSFetchRequestResult>=NSFetchRequest(entityName:"Favourites")
        favouriteEntity.predicate=NSPredicate(format:"streamID=%d", streamID)
        let fetchedFavourites=try! context.fetch(favouriteEntity)
        
        context.delete(fetchedFavourites[0] as! NSManagedObject)
        save()
    }
    
    class func isAlreadyFavourited(_ streamID:UInt)->Bool
    {
        let favouriteEntity:NSFetchRequest<NSFetchRequestResult>=NSFetchRequest(entityName:"Favourites")
        favouriteEntity.predicate=NSPredicate(format:"streamID=%d", streamID)
        let fetchedFavourites=try! context.fetch(favouriteEntity)
        
        if(fetchedFavourites.count>0)
        {
            return true
        }
        
        return false
    }
    
    class func getFavourites(_ vType:Int)->[NSManagedObject]
    {
        let favouritesRequest:NSFetchRequest<NSFetchRequestResult>=NSFetchRequest(entityName:"Favourites")
        favouritesRequest.predicate=NSPredicate(format:"vType=%d", vType)
        return try! context.fetch(favouritesRequest) as! [NSManagedObject]
    }
    
    class func addToRelationships(_ identifier : String, playlistName : String){
        
        let selectedPlaylist = getPlaylist(playlistName)
        let selectedSong = getSong(identifier)
        
        //add song reference to songs relationship (in playlist entity)
        let playlist = selectedPlaylist.mutableSetValue(forKey: "songs")
        playlist.add(selectedSong)
        
        //add playlist reference to playlists relationship (in song entity)
        let inPlaylists = selectedSong.mutableSetValue(forKey: "playlists")
        inPlaylists.add(selectedPlaylist)
        
        save()
    }
    
    class func removeFromRelationships(_ identifier : String, playlistName : String){
        let selectedPlaylist = getPlaylist(playlistName)
        let selectedSong = getSong(identifier)
        
        //delete song reference in songs relationship (in playlist entity)
        let playlist = selectedPlaylist.mutableSetValue(forKey: "songs")
        playlist.remove(selectedSong)
        
        //remove from playlist reference in playlists relationship (in song entity)
        let inPlaylists = selectedSong.mutableSetValue(forKey: "playlists")
        inPlaylists.remove(selectedPlaylist)
        
        save()
    }
    
    class func addNewSong(_ vidInfo : VideoDownloadInfo) {
        
        let video = vidInfo.video
        let playlistName = vidInfo.playlistName
        
        //save to CoreData
        let newSong = NSEntityDescription.insertNewObject(forEntityName: "Song", into: context)
        
        newSong.setValue(video.identifier, forKey: "identifier")
        newSong.setValue(video.title, forKey: "title")
        
        var expireDate = video.expirationDate
        expireDate = expireDate!.addingTimeInterval(-60*60) //decrease expire time by 1 hour
        newSong.setValue(expireDate, forKey: "expireDate")
        newSong.setValue(true, forKey: "isDownloaded")
        
        let duration = video.duration
        let durationStr = MiscFuncs.stringFromTimeInterval(duration)
        newSong.setValue(duration, forKey: "duration")
        newSong.setValue(durationStr, forKey: "durationStr")
        
        var streamURLs = video.streamURLs
        //  let desiredURL = (streamURLs![22] != nil ? streamURLs[22] : (streamURLs[18] != nil ? streamURLs[18] : streamURLs[36]))! as NSURL
        //  newSong.setValue("\(desiredURL)", forKey: "streamURL")
        
        let large = video.largeThumbnailURL
        let medium = video.mediumThumbnailURL
        let small = video.smallThumbnailURL
        let imgData = try! Data(contentsOf: (large != nil ? large : (medium != nil ? medium : small))!)
        newSong.setValue(imgData, forKey: "thumbnail")
        
        addToRelationships(video.identifier, playlistName: playlistName)
        save()
    }
    
    //deletes song only if not in other playlists
    class func deleteSong(_ identifier : String, playlistName : String){
        
        removeFromRelationships(identifier, playlistName: playlistName)
        
        let selectedSong = getSong(identifier)
        let inPlaylists = selectedSong.mutableSetValue(forKey: "playlists")
        
        if (inPlaylists.count < 1){
            
            //allows for redownload of deleted song
            let dict = ["identifier" : identifier]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "resetDownloadTasksID"), object: nil, userInfo: dict as [AnyHashable: Any])
            
            let fileManager = FileManager.default
            
            let isDownloaded = selectedSong.value(forKey: "isDownloaded") as! Bool
            
            //remove item in both documents directory and persistentData
            if isDownloaded {
                let filePath0 = MiscFuncs.grabFilePath("\(identifier).mp4")
                let filePath1 = MiscFuncs.grabFilePath("\(identifier).m4a")
                
                do {
                    try fileManager.removeItem(atPath: filePath0)
                } catch _ {
                }
                
                do {
                    try fileManager.removeItem(atPath: filePath1)
                } catch _ {
                }
            }
            context.delete(selectedSong)
        }
        save()
    }
    
    class func save()
    {
        do
        {
            try context.save()
        }
        catch _
        {
            
        }
    }
}
