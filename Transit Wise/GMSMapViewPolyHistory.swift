//
//  GMSMapViewPathHistory.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 12/16/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import Foundation
import GoogleMaps

/// Custum sub class of GMSMapView so that polylines can be stored
class GMSMapViewWithPolyHistory: GMSMapView{
    var polylines : [GMSPolyline]? = [GMSPolyline()]
    //FIXME: Fix adding polylines to this class
}