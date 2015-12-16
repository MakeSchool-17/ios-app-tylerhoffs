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

class HomeViewController: UIViewController {
    
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var tripPlannerView: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var directionButton: UIButton!
    var viewDown: Bool = false
    @IBOutlet weak var tripPlannerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.cameraWithLatitude(-25.7561672,
            longitude:28.2289275, zoom:12)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        
        // Parallax Header Setup
        let header = mapView
        mainTableView.parallaxHeader.view = header
        mainTableView.parallaxHeader.height = 400
        mainTableView.parallaxHeader.mode = MXParallaxHeaderMode.Fill
        mainTableView.parallaxHeader.minimumHeight = 200
        
        //Looks for single or multiple taps.
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        //view.addGestureRecognizer(tap)

    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text = String(format: "Height %ld", indexPath.row * 10)
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
        print("Button!")
        if(!self.viewDown){
            
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            
            /*var tripPlannerFrame = self.tripPlannerView.frame
            tripPlannerFrame.origin.y = 0
            self.tripPlannerView.frame = tripPlannerFrame
                
            var tableViewFrame = self.mainTableView.frame
            tableViewFrame.origin.y = tripPlannerFrame.height
            self.mainTableView.frame = tableViewFrame */
                var tripPlannerFrame = self.tripPlannerView.frame
                tripPlannerFrame.origin.y = 0
                
                
                
                
                self.tripPlannerView.frame = tripPlannerFrame

            
                
  
                }, completion: { finished in
                    print("View Moved!")
                    //self.viewDown = true
                    self.tripPlannerBottomConstraint.constant = -156.00
                    UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                        
                        let tableHeader = self.mainTableView.parallaxHeader
                        tableHeader.height = self.mainView.frame.height - 50
                        self.mainTableView.parallaxHeader.height = tableHeader.height
                        self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
                        
                        
                        }, completion: { finished in
                            print("View Moved2!")
                    })
            })
        }
    }
    
    
    @IBAction func cancelButtonTap(sender: AnyObject) {
        print("Button!")
        if(!self.viewDown){
            
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                
                
                let tableHeader = self.mainTableView.parallaxHeader
                tableHeader.height = 400
                self.mainTableView.parallaxHeader.height = tableHeader.height
                self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
                
                
                }, completion: { finished in
                    print("View Moved!")
                    self.tripPlannerBottomConstraint.constant = 19
                    UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                        var tripPlannerFrame = self.tripPlannerView.frame
                        tripPlannerFrame.origin.y = -156

                        self.tripPlannerView.frame = tripPlannerFrame
                        
                        
                        
                        }, completion: { finished in
                            print("View Moved2!")
                    })
            })
        }

    }
    
    @IBAction func searchButtonTap(sender: AnyObject) {
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            
            
            let tableHeader = self.mainTableView.parallaxHeader
            tableHeader.height = 110
            self.mainTableView.parallaxHeader.height = tableHeader.height
            self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
            
            
            }, completion: { finished in
                print("View Moved!")
            })
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
