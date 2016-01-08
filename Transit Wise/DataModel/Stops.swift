//
//  Stops.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 1/7/16.
//  Copyright © 2016 Transit Wise. All rights reserved.
//

import Foundation
import SwiftyJSON

class Stop{
    var _id: String?
    var name: String?
    var agencies: [Agency]?
    var loc: Path.Coordinates?
    var distance: Float?
    
    convenience init(json: JSON){
        self.init()
        self._id = json["_id"].string
        self.name = json["name"].string
        //TODO: Get Agency and Category
        self.loc = Path.Coordinates(coord: json["loc"])
        self.distance = json["distance"].float
    }
}