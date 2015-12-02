//
//  Path.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 11/25/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import Foundation
import SwiftyJSON

class Path{
    struct Coordinates{
        var long: String?
        var lat: String?
        
        init(coord: JSON){
            self.lat = coord[0].stringValue
            self.long = coord[1].stringValue
        }
    }
    
    var points: [Coordinates]?
    
    init(points: [Coordinates]){
        self.points = points
    }
}