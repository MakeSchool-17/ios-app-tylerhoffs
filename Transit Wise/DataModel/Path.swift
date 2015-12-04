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

    /**
     *  Class representing coordinates. Could be replaced by Native class depending on Map system chosen
     */
    class Coordinates{
        var long: Double?
        var lat: Double?

        init(coord: JSON){
        self.lat    = coord[0].doubleValue
        self.long   = coord[1].doubleValue
        }
    }

    var points: [Coordinates]?

    init(points: [Coordinates]){
        self.points = points
    }
}