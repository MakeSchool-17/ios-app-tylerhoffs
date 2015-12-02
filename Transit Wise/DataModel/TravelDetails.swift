//
//  TravelDetails.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 11/25/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import Foundation
/// Total Transit, Walk, and Wait distance and time
class TravelDetails {
    
    class Transit {
        var distance: Float?
        var time: Int?
        
        init(distance: Float, time: Int){
            self.distance = distance
            self.time = time
        }
    }
    
    class Walk {
        var distance: Float?
        var time: Int?
        
        init(distance: Float, time: Int){
            self.distance = distance
            self.time = time
        }
    }
    
    class Wait {
        var time: Int?
        
        init(time: Int){
            self.time = time
        }
    }
    
    var transit: Transit?
    var walk: Walk?
    var wait: Wait?
    
    /**
     Initializer
     
     - parameter transit_distance: (transit-> distance)
     - parameter transit_time:     (transit-> time)
     - parameter walk_distance:    (walk-> distance)
     - parameter walk_time:        (walk-> time)
     - parameter wait_time:        (wait-> time)
     
     */
    init(transit_distance: Float, transit_time: Int, walk_distance: Float, walk_time: Int, wait_time: Int){
        self.transit = Transit(distance: transit_distance, time: transit_time)
        self.walk = Walk(distance: walk_distance, time: walk_time)
        self.wait = Wait(time: wait_time)
        
    }
    
}