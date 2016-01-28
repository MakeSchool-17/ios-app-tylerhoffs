//
//  MapViewController.swift
//  Transit Wise
//
//  Created by Tyler Hoffman on 2015/12/11.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import UIKit
import MXParallaxHeader
import GoogleMaps
import Alamofire
import SwiftyJSON

class MapViewController: UIViewController {
    var myTrip = Trip()
    let myRoute = Routes()
    let apiClient = RwtToAPIHelper()
    var mapView: GMSMapView?
    @IBOutlet weak var directionsTableView: UITableView!
    @IBOutlet weak var departTimeLabel: UILabel!
    @IBOutlet weak var arriveTimeLabel: UILabel!
    var locationManager = CLLocationManager()
    
    override func viewDidAppear(animated: Bool) {
        
        self.myTrip.createPolylines(mapView!)
        self.directionsTableView.reloadData()
        self.departTimeLabel.text = "Depart at: " + self.calcTime((self.myTrip.time?.start)!)
        self.arriveTimeLabel.text = "Arrive at: " + self.calcTime((self.myTrip.time?.end)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        let camera = GMSCameraPosition.cameraWithLatitude(-26.15041,
            longitude:28.01562, zoom:16)
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        
        // Parallax Header Setup
        //let header = mapView
        directionsTableView.parallaxHeader.view = mapView //header
        directionsTableView.parallaxHeader.height = 400
        directionsTableView.parallaxHeader.mode = MXParallaxHeaderMode.Fill
        directionsTableView.parallaxHeader.minimumHeight = 200
        
        //Locaition Manager setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()


    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.myTrip.legs?.count{
            return count + 2
        }
        else{
            return 0
        }
        
    }
    
    //Function to calculate time from minutes from Monday 00:00
    func calcTime(minutes: Int) -> String{
        let timeToday = minutes % 1440
        let minutes = timeToday % 60
        let hours = Int(timeToday/60)
        var timeString = ""
        if(minutes < 10){
            timeString = "\(hours)" + ":0" + "\(minutes)"
        }else{
            timeString = "\(hours)" + ":" + "\(minutes)"
        }
        
        return timeString
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("directionCell", forIndexPath: indexPath) as! DirectionCell
            cell.legNameLabel.text = "Depart"
            cell.legTimeLabel.text = calcTime((self.myTrip.time?.start)!)
            cell.mapKeyImage.image = UIImage(named: "start")
            return cell
            
        }
        else if(indexPath.row == ((self.myTrip.legs?.count)! + 1)){
            let cell = tableView.dequeueReusableCellWithIdentifier("directionCell", forIndexPath: indexPath) as! DirectionCell
            cell.legNameLabel.text = "Arrive"
            cell.legTimeLabel.text = calcTime((self.myTrip.time?.end)!)
            cell.mapKeyImage.image = UIImage(named: "end")
            return cell
        }
        else if (self.myTrip.legs![indexPath.row-1].pathType == "Walk"){
            let cell = tableView.dequeueReusableCellWithIdentifier("directionCell", forIndexPath: indexPath) as! DirectionCell
            let distance = self.myTrip.legs![indexPath.row-1].distance!
            if(distance > 1){
                cell.legNameLabel.text = self.myTrip.legs![indexPath.row-1].pathType! + " for \(distance)km"
            }
            else{
                cell.legNameLabel.text = self.myTrip.legs![indexPath.row-1].pathType! + " for \(Int(distance*1000))m"
            }
            cell.legTimeLabel.text = "\((self.myTrip.legs![indexPath.row-1].time?.duration)!)" + " mins"
            cell.mapKeyImage.image = UIImage(named: "walk")
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("busDirectionCell", forIndexPath: indexPath) as! BusDirectionCell
            cell.busNameLabel.text = self.myTrip.legs![indexPath.row-1].route
            cell.busStopStart.text = self.myTrip.legs![indexPath.row-1].fromName
            cell.busStopEnd.text = self.myTrip.legs![indexPath.row-1].toName
            cell.legStartTimeLabel.text = calcTime((self.myTrip.legs![indexPath.row-1].time?.start)!)
            print((self.myTrip.legs![indexPath.row-1].time?.start)!)
            cell.legArriveTimeLabel.text = calcTime((self.myTrip.legs![indexPath.row-1].time?.end)!)
            if((self.myTrip.legs![indexPath.row-1].agency?.name)! == "Gautrain"){
                cell.mapKeyImage.image = UIImage(named: "train")
            }
            else if((self.myTrip.legs![indexPath.row-1].agency?.name)! == "Metrorail Gauteng"){
                cell.mapKeyImage.image = UIImage(named: "train")
            }
            else{
                cell.mapKeyImage.image = UIImage(named: "busicon")
            }
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        print((self.myTrip.legs?.count)!)
        if(indexPath.row == 0){
            return 40
        }
        else if(indexPath.row == ((self.myTrip.legs?.count)! + 1)){
            return 40
        }
        else if (self.myTrip.legs![indexPath.row-1].pathType == "Walk"){
            return 40
        }else{
            return 93
        }
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row > 0 && indexPath.row < (myTrip.legs?.count)!+1{
            myTrip.focusOnLeg(mapView!, leg: myTrip.legs![indexPath.row-1], depart: nil, arrive:  nil)
        }
        else if indexPath.row == 0{
            myTrip.focusOnLeg(mapView!, leg: myTrip.legs![indexPath.row], depart: true, arrive:  nil)
        }
        else{
            myTrip.focusOnLeg(mapView!, leg: myTrip.legs![indexPath.row-2], depart: nil, arrive:  true)
        }
    }

    deinit {
        self.directionsTableView = nil
    }
    
}

extension MapViewController: CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapView!.myLocationEnabled = true
            
        }
    }
}
