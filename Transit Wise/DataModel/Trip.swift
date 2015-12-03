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
                let _stations = extractStationsFromJSON(leg.1["_stations"])
                let agency = extractAgencyFromJSON(leg.1["agency"])
                let bg = extractBgFromJSON(leg.1["bg"])
                
                let newLeg = Leg(path: path, instruction: leg.1["instructions"].stringValue, pathType: leg.1["pathtype"].stringValue, station: leg.1["station"].stringValue, distance: leg.1["distance"].floatValue, time: legTime, bgColour: bg, _stations: _stations, dest: leg.1["dest"].stringValue, fromName: leg.1["fromname"].stringValue, toName: leg.1["toname"].stringValue, route: leg.1["route"].stringValue, service: leg.1["service"].stringValue, transfers: leg.1["transfers"].boolValue, agency: agency, cost: leg.1["cost"].floatValue, discounted: leg.1["discounted"].boolValue)
                
                legs?.append(newLeg)
                
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
    
    func extractStationsFromJSON(_stations: JSON) -> _Stations{
        let start = Station(_id: _stations["start"]["_id"].stringValue, location: Path.Coordinates(coord: _stations["start"]["loc"]), name: _stations["start"]["name"].stringValue, order: _stations["start"]["order"].intValue, zone: _stations["start"]["zone"].intValue, region: _stations["start"]["region"].stringValue, attrib: _stations["start"]["attrib"].stringValue)
        
        var points: [Station] = []
        for point in _stations["points"]{
            points.append(Station(_id: point.1["_id"].stringValue, location: Path.Coordinates(coord: point.1["loc"]), name: point.1["name"].stringValue, order: point.1["order"].intValue, zone: point.1["zone"].intValue, region: point.1["region"].stringValue, attrib: point.1["attrib"].stringValue))
        }
        
        let end = Station(_id: _stations["end"]["_id"].stringValue, location: Path.Coordinates(coord: _stations["end"]["loc"]), name: _stations["end"]["name"].stringValue, order: _stations["end"]["order"].intValue, zone: _stations["end"]["zone"].intValue, region: _stations["end"]["region"].stringValue, attrib: _stations["end"]["attrib"].stringValue)
        
        return _Stations(start: start, points: points, end: end)
    }
    
    func extractAgencyFromJSON(agency: JSON) -> Agency{
        return Agency(name: agency["name"].stringValue, id: agency["id"].stringValue, url: agency["url"].stringValue)
        
    }
    
    func extractBgFromJSON(bg: JSON) -> Leg.BgColour{
        return Leg.BgColour(json: bg)
    }
}
