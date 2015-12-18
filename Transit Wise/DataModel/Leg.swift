//
//  SingleLeg.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 11/25/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import Foundation
import SwiftyJSON
import GoogleMaps

/// A single leg of the trip
class Leg {
    
//MARK: Custom type
    /**
    *  Route Text background in RGB
    */
    class BgColour{
        var Red: Int
        var Green: Int
        var Blue: Int
        
        /**
         bgColour Initializer
         
         - parameter R: (bg->[0])
         - parameter G: (bg->[1])
         - parameter B: (bg->[2])
         
         */
        init(json: JSON){
            self.Red   = json[0].intValue
            self.Green = json[1].intValue
            self.Blue  = json[2].intValue
        }
    }

    var path: Path?             ///path of coordinates
    var instructions: String?   ///instructions to user
    var station: String?        ///destination stop/terminal
    var distance: Float?        ///total distance of leg
    var time: Time?             ///Time deatils of leg
    var bgColour: BgColour?     ///Background colour of route text
    var _stations: _Stations?   ///start, end and all points on that route
    var dest: String?           ///name of destination
    var fromName: String?       ///name of station/terminal where route starts
    var toName: String?         ///name of station/terminal where route is going
    var route: String?          ///name of route
    var service: String?        ///the routes service or code
    var transfers: Bool?        ///whether or not there are transfers during the route
    var pathType: String?       ///type of service
    var agency: Agency?         ///Agency providing service, for attribution
    var cost: Float?            ///cost of leg in ZAR
    var discounted: Bool?       ///whether there are discounts applicable
    var legs: [Leg]?            ///Array of legs if this is a grouped leg
    var group: Bool?            ///Whether this is a group leg or not
    var polyline: GMSPolyline?   ///Polyline to be displayed on map

    
//MARK: Initializers

    /**
     Walking leg Initializer
     */
    init(path: Path, instruction: String, pathType: String, station: String, distance: Float, time: Time){
        self.path         = path
        self.instructions = instruction
        self.pathType     = pathType
        self.station      = station
        self.distance     = distance
        self.time         = time
    }

    /**
     Rail/Bus leg convenience Initializer
     */
    convenience init(path: Path, instruction: String, pathType: String, station: String, distance: Float, time: Time, bgColour: BgColour, _stations: _Stations, dest: String, fromName: String, toName: String, route: String, service: String, transfers: Bool, agency: Agency, cost: Float, discounted: Bool){
        self.init(path: path,instruction: instruction, pathType: pathType, station: station, distance: distance, time: time)

        self.bgColour     = bgColour
        self._stations    = _stations
        self.dest         = dest
        self.fromName     = fromName
        self.toName       = toName
        self.route        = route
        self.service      = service
        self.transfers    = transfers
        self.agency       = agency
        self.cost         = cost
        self.discounted   = discounted

    }
    
    /**
    Grouped Leg initializer 
     
     */
    init?(group: Bool, pathType: String, start: String, end: String, cost: Float, discount: Bool, time: Time, legs: [Leg]){
        self.group = group
        self.pathType = pathType
        self.fromName = start
        self.toName = end
        self.cost = cost
        self.discounted = discount
        self.time = time
        self.legs = legs
        
    }

}