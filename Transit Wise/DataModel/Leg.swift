//
//  SingleLeg.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 11/25/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import Foundation

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
        init(red R: Int, green G: Int, blue B: Int){
            self.Red   = R
            self.Green = G
            self.Blue  = B
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

    
//MARK: Initializers

    /**
     Walking leg Initializer
     */
    init(path: Path?, instruction: String?, pathType: String?, station: String?, distance: Float?, time: Time?){


    }
    
    /**
     Rail/Bus leg convenience Initializer
     */
    convenience init(path: Path?, instruction: String?, pathType: String?, station: String?, distance: Float?, time: Time?, bgColour: BgColour?, _stations: _Stations?, dest: String?, fromName: String?, toName: String?, route: String?, service: String?, transfers: Bool?, agency: Agency?, cost: Float?, discounted: String?){
        self.init(path: path,instruction: instruction, pathType: pathType, station: station, distance: distance, time: time)
        
        
    }

}