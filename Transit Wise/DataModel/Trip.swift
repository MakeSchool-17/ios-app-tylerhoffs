//
//  Trip.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 11/25/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import Foundation
import SwiftyJSON
import GoogleMaps
import UIKit

/// Contains all details of a trip from one point to final destination.
class Trip {
    var cost: Float?
    var shortCode: String?
    var travelDetails: TravelDetails?
    var time: Time?
    var legs: [Leg]?
    
    let styles = [GMSStrokeStyle .solidColor(UIColor.greenColor()), GMSStrokeStyle .solidColor(UIColor.clearColor())] //Colours for stroke of walking path
    let lengths = [10, 8]// Length of styles. Colour and clear
    var fullPath: GMSMutablePath?
    
//MARK: Initializers
    init(){
        
    }
    
    /**
     Function to initialize values using JSON
     
     - parameter json: JSON data containing result for directions from API
     */
    func JSONinit(json: JSON){
        self.cost          = json["cost"].floatValue
        self.shortCode     = json["short"].stringValue
        self.travelDetails = extractTravelDetailsFromJSON(json)
        self.time          = extractTimeDetailsFromJSON(json["time"])
        self.legs          = extractLegsFromJSON(json["legs"])
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
            }else if leg.1["pathtype"] == "Group"{
                let innerLegs = extractLegsFromJSON(leg.1["legs"])
                let newLeg = Leg(group: true, pathType: leg.1["pathtype"].stringValue, start: leg.1["start"].stringValue, end: leg.1["end"].stringValue, cost: leg.1["cost"].floatValue, discount: leg.1["discounted"].boolValue, time: legTime, legs: innerLegs)
                
                legs.append(newLeg!)
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
    
//MARK: Map Interactions
    /**
    Create the polylines and add them to each leg of the trip
    
    - parameter mapView: Map that they will be placed on
    */
    func createPolylines(mapView: GMSMapView){
        self.fullPath = GMSMutablePath()
        for leg in self.legs!{
            if leg.pathType! == "Group"{
                for innerLeg in leg.legs!{
                    workWithLeg(innerLeg, mapview: mapView)
                }
            }else{
                workWithLeg(leg, mapview: mapView)
            }
        }
        
        addLegMarkers(mapView)
        focusCameraOnTrip(mapView)

    }

    /**
     Focus map camera on specific legs of trip
     
     - parameter mapView: GMSMapView that camera is on
     - parameter leg:     leg that needs focus
     - parameter depart:  Whether focus should be placed on departure point
     - parameter arrive:  Whetehr focus should be placed on arrival destination point
     */
    func focusOnLeg(mapView: GMSMapView, leg: Leg, depart: Bool?, arrive: Bool?){

        let mapBounds = GMSCoordinateBounds(path: leg.polyline!.path)
        let update = GMSCameraUpdate.fitBounds(mapBounds, withPadding: 20)
        mapView.animateWithCameraUpdate(update)
        
        if let depart = depart{
            if depart == true{
                mapView.animateToLocation((leg.polyline?.path.coordinateAtIndex(0))!)
            }
        }
        
        if let arrive = arrive{
            if arrive == true{
                mapView.animateToLocation((leg.polyline?.path.coordinateAtIndex((leg.polyline?.path.count())!-1))!)
            }
        }
        
    }
    
    /**
     Add path of single leg onto map
     
     - parameter leg:     Leg object containing leg to be addded to map
     - parameter mapView: GMSMapView object that leg should be placed on
     */
    func workWithLeg(leg: Leg, mapview: GMSMapView){
        
        let polyline = GMSPolyline()
        
        if leg.pathType == "Walk"{
            polyline.strokeColor = UIColor(colorLiteralRed: 0.333, green: 0.855, blue: 0.471, alpha: 1.00)
            var path: GMSPath = GMSPath()
            
            RwtToAPIHelper().getWalkingPath((leg.path?.points![0])!, end: (leg.path?.points![1])!){response in
                
                if response.error == nil{
                    let encodedRoute = response.json!["routes"][0]["overview_polyline"]["points"].stringValue
                    path = GMSPath(fromEncodedPath: encodedRoute)
                    
                    for (var index: UInt = 0; index < path.count(); ++index){
                        self.fullPath?.addCoordinate(path.coordinateAtIndex(index))
                    }
                    
                    polyline.path = path
                    polyline.strokeWidth = 5
                    polyline.spans = GMSStyleSpans(polyline.path, self.styles, self.lengths, kGMSLengthRhumb)
                    polyline.map = mapview
                    leg.polyline = polyline
                    self.focusCameraOnTrip(mapview)
                }else{
                    print(response.error)
                }
                
            }

        }else{
            let path = GMSMutablePath()
            
            switch leg.pathType!{
            case "Bus":
                polyline.strokeColor = UIColor(colorLiteralRed: 0.353, green: 0.522, blue: 0.984, alpha: 1.00)
            case "Rail":
                polyline.strokeColor = UIColor(colorLiteralRed: 0.353, green: 0.522, blue: 0.984, alpha: 1.00)
            default:
                polyline.strokeColor = UIColor(colorLiteralRed: 0.353, green: 0.522, blue: 0.984, alpha: 1.00)
            }
            
            for point in (leg.path?.points)!{
                path.addLatitude(point.lat!, longitude: point.long!)
            }
            
            for (var index: UInt = 0; index < path.count(); ++index){
                self.fullPath?.addCoordinate(path.coordinateAtIndex(index))
            }
            
            polyline.path = path
            polyline.strokeWidth = 4
            polyline.map = mapview
            leg.polyline = polyline
        }
        
    }
    
    /**
     Add markers showing ends of each leg on the map
     
     - parameter mapView: GMSMapView where markers should be placed on
     */
    func addLegMarkers(mapView: GMSMapView){
        var marker: GMSMarker
        
        marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake((legs![0].path!.points!.first!.lat)!, (legs![0].path!.points!.first!.long)!)
        marker.icon = UIImage(named: "start")
        marker.map = mapView
        
        for leg in self.legs!{
            if leg.pathType! == "Group"{
                for innerLeg in leg.legs!{
                    marker = GMSMarker()
                    marker.position = CLLocationCoordinate2DMake((innerLeg.path!.points!.last!.lat)!, (innerLeg.path!.points!.last!.long)!)
                    marker.icon = UIImage(named: "mid")
                    marker.map = mapView
                }
            }else{
                marker = GMSMarker()
                marker.position = CLLocationCoordinate2DMake((leg.path!.points!.last!.lat)!, (leg.path!.points!.last!.long)!)
                marker.icon = UIImage(named: "mid")
                marker.map = mapView
            }
        }
        marker.icon = UIImage(named: "end")
    }
   
    /**
     Move camera to focus on the polyline drawn of the trip
     
     - parameter mapView: GSMMapView where camera should be updated
     */
    func focusCameraOnTrip(mapView: GMSMapView){
        let mapBounds = GMSCoordinateBounds(path: self.fullPath)
        //mapView.camera = mapView.cameraForBounds(mapBounds, insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        let update = GMSCameraUpdate.fitBounds(mapBounds, withPadding: 20)
        mapView.moveCamera(update)
        //mapView.camera = GMSCameraPosition.cameraWithTarget(mapView.camera.target, zoom: 16)
    }
}
