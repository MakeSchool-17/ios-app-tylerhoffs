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
    var filter_state: Bool?

    init(name: String?, id: String?, url: String?){
        self.name = name
        self._id  = id
        self.url  = url
    }
    
    convenience init(name: String?, id: String?, url: String?, filter: Bool?){
        self.init(name: name, id: id, url: url)
        self.filter_state = filter
    }
}