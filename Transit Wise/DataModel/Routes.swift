//
//  Routes.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 1/8/16.
//  Copyright © 2016 Transit Wise. All rights reserved.
//

import Foundation
import SwiftyJSON
/// Class storing available routes of directions received from api call
class Routes{
    var trips: [Trip]?  //List of Trips that could be taken
    
    init(){
        
    }
    
    func JSONinit(json: JSON){
        trips = []
        
        for result in json["result"]{
            let trip = Trip()
            trip.JSONinit(result.1)
            trips?.append(trip)
        }
    }
}
