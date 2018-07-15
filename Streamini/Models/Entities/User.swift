//
//  User.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class User: NSObject
{
    var id: Int = 0
    var name = ""
    var sname = ""
    var avatar: String? = ""
    var likes: Int = 0
    var recent: Int = 0
    var followers: Int = 0
    var following: Int = 0
    var streams: Int = 0
    var blocked: Int = 0
    var desc = ""
    var isLive = false
    var isFollowed = false
    var isBlocked = false
    var subscription = ""
}
