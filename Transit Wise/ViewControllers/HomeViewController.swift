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

class HomeViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate, GMSMapViewDelegate {
    
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var tripPlannerView: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var tripPlannerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    @IBOutlet weak var slideCancelButton: UIButton!
    @IBOutlet weak var dropShadowImage: UIImageView!
    @IBOutlet weak var dropShadowImage2: UIImageView!
    
    var viewDown: Bool = false
    var locationManager = CLLocationManager()
    var mapView : GMSMapView?
    var didFindMyLocation: Bool = true
    var tableViewStatus = 0
    var searchActive = false
    var pickedPlace: GMSPlace?
    var placesClient: GMSPlacesClient?
    var predictions: [GMSAutocompletePrediction]?
    let regularFont = UIFont.systemFontOfSize(UIFont.labelFontSize())
    let boldFont = UIFont.boldSystemFontOfSize(UIFont.labelFontSize())
    let saBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: -24.940233, longitude: 27.000579), coordinate: CLLocationCoordinate2D(latitude: -26.955361, longitude: 29.098968))
    
    var startLocation: SearchLocation?
    var endLocation: SearchLocation?
    var currentLocation: SearchLocation?
    let apiHelper = RwtToAPIHelper()
    var nearbyStations: [Stop]?
    var availableRoutes: Routes?
    var centerMarker: GMSMarker?
    var currentTrip: Trip?
    var parallaxHeight: Int?
    var tableColors: [[Int]] = [[69,181,230],[69,230,131],[69,211,230],[230,147,69],[120,69,230],[230,69,72]]
    var previousColorIndex: Int = 0
    var textFieldIndex: Int = 0
    
    var foundCurrent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parallaxHeight = Int(self.view.frame.height) - 250
        self.setNeedsStatusBarAppearanceUpdate()
        self.getOptions()
        placesClient = GMSPlacesClient()
        startLocation = SearchLocation()
        endLocation = SearchLocation()
        currentLocation = SearchLocation()
        nearbyStations = []
        
        mainTableView.rowHeight = 100
        //mainTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        mainTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
        let camera = GMSCameraPosition.cameraWithLatitude(-25.7561672,
            longitude:28.2289275, zoom:16)
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        mapView!.delegate = self
        mapView!.settings.myLocationButton = true
        
        centerMarker = GMSMarker()
        centerMarker!.appearAnimation = kGMSMarkerAnimationPop
        centerMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
        centerMarker?.title = "Current Location"
        centerMarker!.map = mapView
        
        //Locaition Manager setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //mapView!.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        
        // Parallax Header Setup
        let header = mapView
        mainTableView.parallaxHeader.view = header
        mainTableView.parallaxHeader.height = CGFloat(self.parallaxHeight!)
        mainTableView.parallaxHeader.mode = MXParallaxHeaderMode.Fill
        mainTableView.parallaxHeader.minimumHeight = 200
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tripPlannerView.addGestureRecognizer(tap)
        //mapView?.addGestureRecognizer(tap)
        
        if #available(iOS 9.1, *) {
            let homeShortcut = UIApplicationShortcutItem(type: "com.transitwise.takemehome", localizedTitle: "Take Me Home", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .Home), userInfo: nil)
            let workShortcut = UIApplicationShortcutItem(type: "com.transitwise.takemework", localizedTitle: "Take Me to Work", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .Bookmark), userInfo: nil)
            UIApplication.sharedApplication().shortcutItems = [homeShortcut, workShortcut]
        } else {
            // Fallback on earlier versions
        }
        
        
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableViewStatus == 1){
            if let predictions = predictions{
                return predictions.count
            }else{
                return 0
            }
        }else if (tableViewStatus == 0){
            return (nearbyStations?.count)! // TODO: Get Stations List
        }else if (tableViewStatus == 2){
            print("AVAILABLE ROUTES \(self.availableRoutes?.trips?.count)")
            return (availableRoutes?.trips!.count)!
        }
        else if (tableViewStatus == 3){
            if let predictions = predictions{
                return predictions.count
            }else{
                return 0
            }
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(tableViewStatus == 1){
            return "Search Results"
        }
        else if(tableViewStatus == 3){
            return "Search Results"
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Table View Statuses:
        // 0: Display bus stops
        // 1: Display search results on trip planner page
        // 2: Display trips available
        // 3: Display search results on main page
        
        var identifier = ""
        
        if (tableViewStatus == 0){
            identifier = "busStopCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! BusStopCell
            cell.contentView.backgroundColor = getRandomColor()
            cell.stopNameLabel.text = nearbyStations![indexPath.row].name! + " Stop"
            if(nearbyStations![indexPath.row].distance! > 1){
                cell.stopDistanceLabel.text = "\(nearbyStations![indexPath.row].distance!)km"
            }
            else{
                let metres = Int(nearbyStations![indexPath.row].distance! * 1000)
                cell.stopDistanceLabel.text = "\(metres)m"
            }
            return cell
        }
        else if(tableViewStatus == 1){
            identifier = "searchCell"
            
            let bolded = predictions![indexPath.row].attributedPrimaryText.mutableCopy() as! NSMutableAttributedString
            bolded.enumerateAttribute(kGMSAutocompleteMatchAttribute, inRange: NSMakeRange(0, bolded.length), options: []) { (value, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let font = (value == nil) ? self.regularFont : self.boldFont
                bolded.addAttribute(NSFontAttributeName, value: font, range: range)
            }
            
            let city = predictions![indexPath.row].attributedSecondaryText.mutableCopy() as! NSMutableAttributedString
            city.enumerateAttribute(kGMSAutocompleteMatchAttribute, inRange: NSMakeRange(0, city.length), options: []) { (value, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let font = (value == nil) ? self.regularFont : self.boldFont
                city.addAttribute(NSFontAttributeName, value: font, range: range)
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! SearchCell
            
            
            cell.addressLabel?.attributedText = bolded
            cell.cityLabel?.attributedText = city
            //self.mainTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            return cell
            
        }
        else if(tableViewStatus == 2){
            identifier = "searchCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! SearchCell
            print(indexPath.row)
            
            cell.addressLabel?.text = self.availableRoutes?.trips![indexPath.row].shortCode
            cell.cityLabel?.text = ""
            return cell
        }
        else if(tableViewStatus == 3){
            identifier = "searchCell"
            
            let bolded = predictions![indexPath.row].attributedPrimaryText.mutableCopy() as! NSMutableAttributedString
            bolded.enumerateAttribute(kGMSAutocompleteMatchAttribute, inRange: NSMakeRange(0, bolded.length), options: []) { (value, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let font = (value == nil) ? self.regularFont : self.boldFont
                bolded.addAttribute(NSFontAttributeName, value: font, range: range)
            }
            
            let city = predictions![indexPath.row].attributedSecondaryText.mutableCopy() as! NSMutableAttributedString
            city.enumerateAttribute(kGMSAutocompleteMatchAttribute, inRange: NSMakeRange(0, city.length), options: []) { (value, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let font = (value == nil) ? self.regularFont : self.boldFont
                city.addAttribute(NSFontAttributeName, value: font, range: range)
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! SearchCell
            
            
            cell.addressLabel?.attributedText = bolded
            cell.cityLabel?.attributedText = city
            
            return cell
            
        }
        else{
            identifier = "recentCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
            return cell
        }
        
    }
    
    
    
    //Generate random colours!
    ///http://martin.ankerl.com/2009/12/09/how-to-create-random-colors-programmatically/
    func hsvToRgb(h: Double, s: Double, v: Double) -> [Int]{
        var r = 0.0
        var g = 0.0
        var b = 0.0
        
        let h_i = Int(h*6)
        let f = h*6 - Double(h_i)
        let p = v * (1 - s)
        let q = v * (1 - f*s)
        let t = v * (1 - (1 - f) * s)
        
        if(h_i==0){
            r = v
            g = t
            b = p
        }
        else if(h_i==1){
            r = q
            g = v
            b = p
        }
        else if(h_i==2){
            r = p
            g = v
            b = t
        }
        else if(h_i==3){
            r = p
            g = q
            b = v
        }
        else if(h_i==4){
            r = t
            g = p
            b = v
        }
        else if(h_i==5){
            r = v
            g = p
            b = q
        }
        return [Int(r*256),Int(g*256),Int(b*256)]
    }
    func getRandomColor() -> UIColor{
        /*
        var h = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        h += 0.618033988749895
        h %= 1

        let rgb = hsvToRgb(Double(h),s: 0.7,v: 0.90)
        
        let color = UIColor(red: CGFloat(rgb[0])/255.0, green: CGFloat(rgb[1])/255.0, blue: CGFloat(rgb[2])/255.0, alpha: 1.0)
        */
        
        var randomNumber = Int(arc4random_uniform(6))
        while(randomNumber == previousColorIndex){
            randomNumber = Int(arc4random_uniform(6))
        }
        previousColorIndex = randomNumber
        let rgb = tableColors[randomNumber]
        let color = UIColor(red: CGFloat(rgb[0])/255.0, green: CGFloat(rgb[1])/255.0, blue: CGFloat(rgb[2])/255.0, alpha: 1.0)
        return color
        
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //selectedWaypoint = waypoints[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        //self.performSegueWithIdentifier("ShowTrip", sender: self)
        if(tableViewStatus == 0){
            startLocation?.name = nearbyStations![indexPath.row].name!
            startLocation?.long = (nearbyStations![indexPath.row].loc?.long)!
            startLocation?.lat = (nearbyStations![indexPath.row].loc?.lat)!
            
            dropTripPlanner()
        }
        else if(tableViewStatus == 1){
            if(textFieldIndex == 1){
                endLocation?.setFromID(predictions![indexPath.row].placeID){response in
                    if response == nil{
                        self.endTextField.text = self.endLocation?.name
                        if let _ = self.endLocation?.lat {
                            if let _ = self.startLocation?.lat{
                                 self.tripSearch()
                            }
                        }
                       
                        print("endLocation SET")
                    }else{
                    // There is an error
                    }
                }
            }
            else{
                startLocation?.setFromID(predictions![indexPath.row].placeID){response in
                    if response == nil{
                        self.startTextField.text = self.startLocation?.name
                        if let _ = self.endLocation?.lat {
                            if let _ = self.startLocation?.lat{
                                self.tripSearch()
                            }
                        }
                        print("startLocation SET")
                    }else{
                        // There is an error
                    }
                }
            }
            
        }
        else if(tableViewStatus == 2){
            currentTrip = availableRoutes?.trips![indexPath.row]
            self.performSegueWithIdentifier("ShowTrip", sender: self)
        }
        else if(tableViewStatus == 3){
            endLocation?.setFromID(predictions![indexPath.row].placeID){response in
                if response == nil{
                    self.dropTripPlanner()
                    self.startLocation = self.currentLocation
                    self.startTextField.text = "Current Location"
                    self.endTextField.text = self.endLocation?.name
                    self.tripSearch()
                }else{
                    // There is an error
                }
            }
            
            
        }
        else{
            self.performSegueWithIdentifier("ShowTrip", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowTrip") {
            let mapViewController = segue.destinationViewController as! MapViewController
            mapViewController.myTrip = currentTrip!
        }
    }
    
    // MARK: - Scroll view delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        NSLog("progress %f", scrollView.parallaxHeader.progress)
    }
    
    // MARK: - Button Actions
    @IBAction func slideCacelTap(sender: AnyObject) {
        self.view.endEditing(true)
        directionButton.hidden = false
        searchActive = false
        tableViewStatus = 0
        mainTableView.rowHeight = 100
        mainTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            let tableHeader = self.mainTableView.parallaxHeader
            tableHeader.height = CGFloat(self.parallaxHeight!)
            self.mainTableView.parallaxHeader.height = tableHeader.height
            self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
            self.mainTableView.parallaxHeader.view?.hidden = false
            self.mainTableView.parallaxHeader.minimumHeight = 200
            
            
            
            }, completion: { finished in
                print("View Moved!")
        })
        
    }
    
    @IBAction func directionButtonTap(sender: UIButton) {
        dropTripPlanner()
    }
    
    func dropTripPlanner(){
        if(!self.viewDown){
            self.viewDown = true
            
            self.view.endEditing(true)
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                //var tripPlannerFrame = self.tripPlannerView.frame
                //tripPlannerFrame.origin.y = -10
                //self.tripPlannerView.frame = tripPlannerFrame
                self.tripPlannerView.transform = CGAffineTransformMakeTranslation(0,148)
                self.dropShadowImage2.transform = CGAffineTransformMakeTranslation(0,157)
                let tableHeader = self.mainTableView.parallaxHeader
                tableHeader.height = self.mainView.frame.height - 55
                self.mainTableView.parallaxHeader.height = tableHeader.height
                self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
                
                
                }, completion: { finished in
                    if self.tableViewStatus == 0 {
                        self.startTextField.text = self.startLocation?.name
                    }
                    //self.tripPlannerBottomConstraint.constant = -130
            })
        }
    }
    
    
    @IBAction func cancelButtonTap(sender: AnyObject) {
        if(self.viewDown){
            self.viewDown = false
            tableViewStatus = 0
            mainTableView.rowHeight = 100
            mainTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            
            //mainTableView.reloadData()
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                
                
                let tableHeader = self.mainTableView.parallaxHeader
                tableHeader.height = CGFloat(self.parallaxHeight!)
                self.mainTableView.parallaxHeader.height = tableHeader.height
                self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
                self.mainTableView.parallaxHeader.minimumHeight = 200
                self.tripPlannerView.transform = CGAffineTransformMakeTranslation(0,0)
                self.dropShadowImage2.transform = CGAffineTransformMakeTranslation(0,0)
                
                
                }, completion: { finished in
                   /* self.tripPlannerBottomConstraint.constant = 19
                    UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                        var tripPlannerFrame = self.tripPlannerView.frame
                        tripPlannerFrame.origin.y = -156
                        
                        self.tripPlannerView.frame = tripPlannerFrame
                        
                        
                        
                        }, completion: { finished in
                            print("View Moved2!")
                    }) */
            })
            
            self.mainTableView.parallaxHeader.view?.hidden = false
        }
        
    }
    
    func tripSearch(){
        //tableViewStatus = 1
        //mainTableView.reloadData()
        
        
        availableRoutes = Routes()
        
        
        apiHelper.getDirectionsCallback((startLocation?.lat)!, startLong: (startLocation?.long)!, startName: (startLocation?.name)!, endLat: (endLocation?.lat)!, endLong: (endLocation?.long)!, endName: (endLocation?.name)!){ response in
            if response.error == nil{
                self.availableRoutes!.JSONinit(response.json!)
                
                self.tableViewStatus = 2
                self.mainTableView.reloadData()
                self.mainTableView.parallaxHeader.height = 90
                self.mainTableView.parallaxHeader.minimumHeight = 90
                self.mainTableView.parallaxHeader.view?.hidden = true
                
            }else{
                print(response.error)
            }
        }
    }
    
    @IBAction func searchButtonTap(sender: AnyObject) {
        self.view.endEditing(true)
        tripSearch()
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

extension HomeViewController{
    
    //Search Bar Delegate Functions
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if(!searchActive){
            directionButton.hidden = true
            searchActive = true
            tableViewStatus = 3
            mainTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            mainTableView.rowHeight = 50
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                let tableHeader = self.mainTableView.parallaxHeader
                tableHeader.height = 0
                self.mainTableView.parallaxHeader.height = tableHeader.height
                self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
                self.mainTableView.parallaxHeader.view?.hidden = true
                
                //self.searchBarLeftConstraint.constant -= 40
                //self.searchBarRightConstraint.constant += 40
                
                self.searchBar.transform = CGAffineTransformMakeTranslation(-40, 0)
                
                self.slideCancelButton.transform = CGAffineTransformMakeTranslation(-80, 0)
                
                }, completion: { finished in
                    print("View Moved!")
            })
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissKeyboard()
        //TODO: Bring back map
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
        directionButton.hidden = false
        self.searchBar.transform = CGAffineTransformMakeTranslation(0, 0)
        self.slideCancelButton.transform = CGAffineTransformMakeTranslation(+80, 0)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        directionButton.hidden = false
        self.searchBar.transform = CGAffineTransformMakeTranslation(0, 0)
        self.slideCancelButton.transform = CGAffineTransformMakeTranslation(+80, 0)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        directionButton.hidden = false
        self.searchBar.transform = CGAffineTransformMakeTranslation(0, 0)
        self.slideCancelButton.transform = CGAffineTransformMakeTranslation(+80, 0)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if NSString(string: searchText).length > 0 {
            placeAutocomplete(searchBar.text!)
        }else{
            self.predictions = []
            self.mainTableView.reloadData()
        }
    }
    
    //Text Field Delegate Funtions
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        tableViewStatus = 1
        mainTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        mainTableView.rowHeight = 50
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            
            
            let tableHeader = self.mainTableView.parallaxHeader
            tableHeader.height = 90
            self.mainTableView.parallaxHeader.height = tableHeader.height
            self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
            self.mainTableView.parallaxHeader.view?.hidden = true
            
            
            }, completion: { finished in
                print("View Moved!")
        })
        if(textField == startTextField!){
            self.textFieldIndex = 0
        }
        else{
            self.textFieldIndex = 1
        }
        if textField.text?.characters.count > 0 {
            
            placeAutocomplete(textField.text!)
        }else{
            self.predictions = []
            self.mainTableView.reloadData()
        }

    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var txtAfterUpdate:NSString = textField.text! as NSString
        
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        if txtAfterUpdate.length > 0 {
            
            placeAutocomplete(txtAfterUpdate as String)
        }else{
            self.predictions = []
            self.mainTableView.reloadData()
        }
        return true
    }
    
    
    func placeAutocomplete(searchText: String) {
        
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
        placesClient?.autocompleteQuery(searchText, bounds: saBounds, filter: filter, callback: { (results, error: NSError?) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
            }
            self.predictions = []
            for result in results! {
                if let result = result as? GMSAutocompletePrediction {
                    self.predictions?.append(result)
                }
            }
            self.mainTableView.reloadData()
        })
    }
    
    //MARK: MapViewDelegate
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        endLocation?.lat = marker.position.latitude
        endLocation?.long = marker.position.longitude
        return false
    }
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        let customInfoWindow = NSBundle.mainBundle().loadNibNamed("CustomInfoWindow", owner: self, options: nil)[0] as! UIView
        if marker.hash == centerMarker?.hash{
            
        }else{
            
        }
        return customInfoWindow
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        print("Start Search")
    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        centerMarker?.position = position.target
    }
    
}

extension HomeViewController: CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapView!.myLocationEnabled = true
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation?.lat = location.coordinate.latitude
            currentLocation?.long = location.coordinate.longitude
        }
        if foundCurrent == true{
            return
        }
        foundCurrent = true
        if let location = locations.first {
            refreshCurrentLocation(location)
            mapView!.camera = GMSCameraPosition(target: location.coordinate, zoom: 16, bearing: 0, viewingAngle: 0)
            
        }
    }
    
}

extension HomeViewController{
    func getOptions(){
        apiHelper.getOptionsCallback(){response in
            if response.error == nil{
                let apiOptions = Options.from((response.json?.dictionaryObject)!)
                let realmHelper = RealmHelper()
                realmHelper.persistOptions(apiOptions!)
                
            }else{
                print(response.error)
            }
        }
    }
    
    func refreshCurrentLocation(location: CLLocation){
        
        apiHelper.getNearbyStation(location.coordinate.latitude, long: location.coordinate.longitude){response in
            if response.error == nil{
                self.nearbyStations = []
                for stop in response.json!["stops"]{
                    self.nearbyStations?.append(Stop(json: stop.1))
                }
                for stops in self.nearbyStations!{
                    stops.addMarker(self.mapView!)
                }
                self.mainTableView.reloadData()
            }else{
                print(response.error)
            }
            
        }
    }
}
