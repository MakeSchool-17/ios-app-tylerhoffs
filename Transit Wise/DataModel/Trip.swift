//
//  Trip.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 11/25/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import Foundation
import SwiftyJSON

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
    
    init(){
        
    }
    
    /**
     Function to initialize values using JSON
     
     - parameter json: JSON data from API
     */
    func JSONinit(json: JSON){
        self.cost = json["result"]["cost"].floatValue
        self.shortCode = json["result"]["short"].stringValue
        extractTravelDetailsFromJSON(json["result"])
        time = extractTimeDetailsFromJSON(json["result"]["time"])
        extractLegsFromJSON(json["result"]["legs"])
    }
    
    func extractTravelDetailsFromJSON(json: JSON){
        self.travelDetails = TravelDetails(transit_distance: json["transit"]["distance"].floatValue, transit_time: json["transit"]["time"].intValue, walk_distance: json["walk"]["distance"].floatValue, walk_time: json["walk"]["time"].intValue, wait_time: json["wait"]["time"].intValue)
    }
    
    func extractTimeDetailsFromJSON(json: JSON) -> Time{
        return Time(start: json["start"].intValue, end: json["end"].intValue, duration: json["len"].intValue, format_start: json["s"].stringValue, format_end: json["e"].stringValue, format_duration: json["d"].stringValue, format_wait: json["w"].stringValue)
    }
    
    func extractLegsFromJSON(json: JSON){
        legs = []
        for leg in json {
            let path = self.extractPathFromJSON(leg.1["path"])
            
            let legTime = extractTimeDetailsFromJSON(leg.1["time"])
            
            //create leg
            
            if leg.1["pathtype"] == "Walk"{
                let newLeg = Leg(path: path, instruction: leg.1["instructions"].stringValue, pathType: leg.1["pathtype"].stringValue, station: leg.1["station"].stringValue, distance: leg.1["distance"].floatValue, time: legTime)
                legs?.append(newLeg)
            }else{
                ///TODO: Create leg with convenience init
                print("Add leg")
            }
            
        }
    }
    
    func extractPathFromJSON(path : JSON) -> Path{
        var coords: [Path.Coordinates] = []
        for coord in path{
            let point = Path.Coordinates(coord: coord.1)
            coords.append(point)
        }
        return Path(points: coords)
    }
}
