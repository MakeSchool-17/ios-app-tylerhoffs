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
    
    init(){
        
    }
    
    /**
     Function to initialize values using JSON
     
     - parameter json: JSON data containing result for directions from API
     */
    func JSONinit(json: JSON){
        self.cost          = json["result"]["cost"].floatValue
        self.shortCode     = json["result"]["short"].stringValue
        self.travelDetails = extractTravelDetailsFromJSON(json["result"])
        self.time          = extractTimeDetailsFromJSON(json["result"]["time"])
        self.legs          = extractLegsFromJSON(json["result"]["legs"])
    }
    
//MARK: JSON Extracters
    
    /**
     Create TravelDetails object from JSON data
     
     - parameter json: JSON data containing a single
     */
    func extractTravelDetailsFromJSON(json: JSON) -> TravelDetails{
        return TravelDetails(transit_distance: json["transit"]["distance"].floatValue, transit_time: json["transit"]["time"].intValue, walk_distance: json["walk"]["distance"].floatValue, walk_time: json["walk"]["time"].intValue, wait_time: json["wait"]["time"].intValue)
    }
    
    /**
     Create Time object from JSON data
     
     - parameter json: JSON data containing time details for a trip, leg or other Travel info
     
     - returns: Time object
     */
    func extractTimeDetailsFromJSON(json: JSON) -> Time{
        return Time(start: json["start"].intValue, end: json["end"].intValue, duration: json["len"].intValue, format_start: json["s"].stringValue, format_end: json["e"].stringValue, format_duration: json["d"].stringValue, format_wait: json["w"].stringValue)
    }
    
    /**
     Create a Leg object from JSON data
     
     - parameter json: JSON data containing array of all Legs
     */
    func extractLegsFromJSON(json: JSON) -> [Leg]{
        var legs: [Leg] = []
        for leg in json {
            let path = self.extractPathFromJSON(leg.1["path"])
            
            let legTime = extractTimeDetailsFromJSON(leg.1["time"])
            
            //create leg
            
            if leg.1["pathtype"] == "Walk"{
                let newLeg = Leg(path: path, instruction: leg.1["instructions"].stringValue, pathType: leg.1["pathtype"].stringValue, station: leg.1["station"].stringValue, distance: leg.1["distance"].floatValue, time: legTime)
                legs.append(newLeg)
            }else{
                let _stations = extractStationsFromJSON(leg.1["_stations"])
                let agency = extractAgencyFromJSON(leg.1["agency"])
                let bg = extractBgFromJSON(leg.1["bg"])
                
                let newLeg = Leg(path: path, instruction: leg.1["instructions"].stringValue, pathType: leg.1["pathtype"].stringValue, station: leg.1["station"].stringValue, distance: leg.1["distance"].floatValue, time: legTime, bgColour: bg, _stations: _stations, dest: leg.1["dest"].stringValue, fromName: leg.1["fromname"].stringValue, toName: leg.1["toname"].stringValue, route: leg.1["route"].stringValue, service: leg.1["service"].stringValue, transfers: leg.1["transfers"].boolValue, agency: agency, cost: leg.1["cost"].floatValue, discounted: leg.1["discounted"].boolValue)
                
                legs.append(newLeg)
                
            }
            
        }
        return legs
    }
    
    /**
     Create Path object from JSON data
     
     - parameter path: JSON data containing list of coordinates representing path of leg
     
     - returns: Path object cointaining list of points with coordinates
     */
    func extractPathFromJSON(path : JSON) -> Path{
        var coords: [Path.Coordinates] = []
        for coord in path{
            let point = Path.Coordinates(coord: coord.1)
            coords.append(point)
        }
        return Path(points: coords)
    }
    
    /**
     Create _Stations object from JSON data
     
     - parameter _stations: JSON data with details of each station on route
     
     - returns: return _Stations object containing Staion object of Start, End and other Points in route
     */
    func extractStationsFromJSON(_stations: JSON) -> _Stations{
        let start = Station(_id: _stations["start"]["_id"].stringValue, location: Path.Coordinates(coord: _stations["start"]["loc"]), name: _stations["start"]["name"].stringValue, order: _stations["start"]["order"].intValue, zone: _stations["start"]["zone"].intValue, region: _stations["start"]["region"].stringValue, attrib: _stations["start"]["attrib"].stringValue)
        
        var points: [Station] = []
        for point in _stations["points"]{
            points.append(Station(_id: point.1["_id"].stringValue, location: Path.Coordinates(coord: point.1["loc"]), name: point.1["name"].stringValue, order: point.1["order"].intValue, zone: point.1["zone"].intValue, region: point.1["region"].stringValue, attrib: point.1["attrib"].stringValue))
        }
        
        let end = Station(_id: _stations["end"]["_id"].stringValue, location: Path.Coordinates(coord: _stations["end"]["loc"]), name: _stations["end"]["name"].stringValue, order: _stations["end"]["order"].intValue, zone: _stations["end"]["zone"].intValue, region: _stations["end"]["region"].stringValue, attrib: _stations["end"]["attrib"].stringValue)
        
        return _Stations(start: start, points: points, end: end)
    }
    
    /**
     Create Agency object from JSON data
     
     - parameter agency: JSON data with agency details
     
     - returns: Agency object with all details of that agency.
     */
    func extractAgencyFromJSON(agency: JSON) -> Agency{
        return Agency(name: agency["name"].stringValue, id: agency["id"].stringValue, url: agency["url"].stringValue)
        
    }
    
    /**
     Create BgColour object from JSON data
     
     - parameter bg: JSON with list of 3 values
     
     - returns: BgColour object with RGB values
     */
    func extractBgFromJSON(bg: JSON) -> Leg.BgColour{
        return Leg.BgColour(json: bg)
    }
}
