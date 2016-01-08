//
//  Stops.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 1/7/16.
//  Copyright © 2016 Transit Wise. All rights reserved.
//

import Foundation
import SwiftyJSON
import GoogleMaps

/// Class to store nearby stations and stops 
class Stop{
    var _id: String?
    var name: String?
    var agencies: [Agency]?
    var loc: Path.Coordinates?
    var distance: Float?
    
    convenience init(json: JSON){
        self.init()
        self._id = json["_id"].string
        self.name = json["name"].string
        //TODO: Get Agency and Category
        self.loc = Path.Coordinates(coord: json["loc"])
        self.distance = json["distance"].float
    }
    
    /**
     Add Marker off stop on MapView
     
     - parameter mapView: GMSMapView on screen where markers must be placed
     */
    func addMarker(mapView: GMSMapView){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake((loc?.lat)!, (loc?.long)!)
        marker.appearAnimation = kGMSMarkerAnimationPop
        //marker.icon = UIImage(named: "flag_icon")
        marker.title = name
        //TODO: marker.snippet = agency and type
        marker.map = mapView
    }
    
}