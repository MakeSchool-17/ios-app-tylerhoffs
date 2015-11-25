//
//  SingleStation.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 11/25/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import Foundation
//Representation of a single Station on a route
class Station {
    var _id: String?
    var location: Path.Coordinates?
    var name: String?
    var order: Int?
    var zone: Int?
    var attrib: String?
    
    /**
     Station Initializer
     
     - parameter _id:      id of station
     - parameter location: coordinates on map of station
     - parameter name:     station name
     - parameter order:    position it appears om route
     - parameter zone:     used for fare calculation
     
     */
    init(_id: String?, location: Path.Coordinates?, name: String?, order: Int?, zone: Int?, region: String?){
            
    }
    
}