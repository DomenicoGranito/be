//
//  Category.swift
//  Streamini
//
//  Created by Vasiliy Evreinov on 14.06.16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class Category: NSObject
{
    var id: Int = 0
    var name = ""
    var subCategories:NSArray!
    var isChannel = false
}
