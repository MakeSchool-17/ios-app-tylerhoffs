//
//  Trip.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 11/25/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import Foundation

/// Contains all details of a trip from one point to final destination.
class Trip {
    var cost: Float?
    var shortCode: String?
    var travelDetails: TravelDetails?
    var time: Time?
    var legs: [Leg]?
    
    /**
     Initializer
    
     - parameter cost:          Cost of the Trip                                (cost)
     - parameter shortCode:     _id of short code used to request sharing URl.  (short)
     - parameter travelDetails: contains total distance and and time spent in   (transit), (walk), and (wait)
     - parameter time:          overall time deatils                            (time)
     - parameter legs:          array of all legs                               (legs)
     
     */
    init(cost: Float?, shortCode: String?, travelDetails: TravelDetails?, time: Time?, legs: [Leg]?){
        
    }
    
}
