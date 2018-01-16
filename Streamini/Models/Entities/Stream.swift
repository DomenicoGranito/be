//
//  Stream.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class Stream: NSObject
{
    var id: Int = 0
    var vType=0
    var videoID=""
    var title = ""
    var cid: Int = 0
    var category = ""
    var year = ""
    var videoDescription = ""
    var brand = ""
    var venue = ""
    var PRAgency = ""
    var musicAgency = ""
    var adAgency = ""
    var eventAgency = ""
    var videoAgency = ""
    var talentAgency = ""
    var streamHash = ""
    var lon: Double = 0
    var lat: Double = 0
    var city = ""
    var ended: NSDate? = nil
    var viewers: Int = 0
    var tviewers: Int = 0
    var rviewers: Int = 0
    var likes: Int = 0
    var shares: Int = 0
    var comments: Int = 0
    var rlikes: Int = 0
    var user = User()   
}

class Video: NSObject
{
    var id: UInt = 0
    var title = ""
    var duration = Double()
    var mediumThumbnailURL: URL? = nil
    var largeThumbnailURL: URL? = nil
    var smallThumbnailURL: URL? = nil
    var expirationDate : NSDate? = nil
    var identifier = ""
    var streamHash = ""
    var streamURLs: [Int]? = nil
    var lon: Double = 0
    var lat: Double = 0
    var city = ""
    var ended: NSDate? = nil
    var viewers: UInt = 0
    var tviewers: UInt = 0
    var rviewers: UInt = 0
    var likes: UInt = 0
    var rlikes: UInt = 0
    var user = User()
}
