//
//  HomeViewController.swift
//  Transit Wise
//
//  Created by Tyler Hoffman on 2015/12/07.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import UIKit
import MXParallaxHeader
import GoogleMaps
import CoreLocation

class HomeViewController: UIViewController,CLLocationManagerDelegate {
    
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var tripPlannerView: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var directionButton: UIButton!
    var viewDown: Bool = false
    var locationManager = CLLocationManager()
    var mapView : GMSMapView?
    var didFindMyLocation: Bool = true
    @IBOutlet weak var tripPlannerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView.rowHeight = 100
        mainTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        mainTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
        let camera = GMSCameraPosition.cameraWithLatitude(-25.7561672,
            longitude:28.2289275, zoom:12)
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        
        //Locaition Manager setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //mapView!.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        
        // Parallax Header Setup
        let header = mapView
        mainTableView.parallaxHeader.view = header
        mainTableView.parallaxHeader.height = 400
        mainTableView.parallaxHeader.mode = MXParallaxHeaderMode.Fill
        mainTableView.parallaxHeader.minimumHeight = 200
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tripPlannerView.addGestureRecognizer(tap)
        //mapView?.addGestureRecognizer(tap)


    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapView!.myLocationEnabled = true
        }
    }
    
   /* func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change[NSKeyValueChangeNewKey] as CLLocation
            mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
            mapView.settings.myLocationButton = true
            
            didFindMyLocation = true
        }
    } */
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("busStopCell", forIndexPath: indexPath)
        //cell.textLabel!.text = String(format: "Height %ld", indexPath.row * 10)
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //selectedWaypoint = waypoints[indexPath.row]
        
        self.performSegueWithIdentifier("ShowTrip", sender: self)
    }
    
    // MARK: - Scroll view delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        NSLog("progress %f", scrollView.parallaxHeader.progress)
    }
    
    // MARK: - Button Actions
    
    @IBAction func directionButtonTap(sender: UIButton) {
        if(!self.viewDown){
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                var tripPlannerFrame = self.tripPlannerView.frame
                tripPlannerFrame.origin.y = 0
                self.tripPlannerView.frame = tripPlannerFrame
                
  
                }, completion: { finished in
                    //self.viewDown = true
                    self.tripPlannerBottomConstraint.constant = -156.00
                    UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                        
                        let tableHeader = self.mainTableView.parallaxHeader
                        tableHeader.height = self.mainView.frame.height - 50
                        self.mainTableView.parallaxHeader.height = tableHeader.height
                        self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
                        
                        
                        }, completion: { finished in
                            print("View Moved!")
                    })
            })
        }
    }
    
    
    @IBAction func cancelButtonTap(sender: AnyObject) {
        if(!self.viewDown){
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                
                
                let tableHeader = self.mainTableView.parallaxHeader
                tableHeader.height = 400
                self.mainTableView.parallaxHeader.height = tableHeader.height
                self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
                
                
                }, completion: { finished in
                    self.tripPlannerBottomConstraint.constant = 19
                    UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                        var tripPlannerFrame = self.tripPlannerView.frame
                        tripPlannerFrame.origin.y = -156

                        self.tripPlannerView.frame = tripPlannerFrame
                        
                        
                        
                        }, completion: { finished in
                            print("View Moved2!")
                    })
            })
            
            mainTableView.bounces = true
        }

    }
    
    @IBAction func searchButtonTap(sender: AnyObject) {
        self.view.endEditing(true)
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            
            
            let tableHeader = self.mainTableView.parallaxHeader
            tableHeader.height = 110
            self.mainTableView.parallaxHeader.height = tableHeader.height
            self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
            
            
            }, completion: { finished in
                print("View Moved!")
        })
        
        mainTableView.bounces = false
    }
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        
        if let identifier = segue.identifier{
            switch identifier {
            case "Add":
                print("ADD")
            case "Cancel":
                print("No Trip")
            default:
                print("No Trip")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
