//
//  Agency.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 11/25/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import Foundation
/// Details of Agency providing service
class Agency {
    var name: String?
    var _id: String?
    var url: String?

    init(name: String?, id: String?, url: String?){
        self.name = name
        self._id  = id
        self.url  = url
    }
}