//
//  OptionsViewController.swift
//  Transit Wise
//
//  Created by Tyler Hoffman on 2016/01/10.
//  Copyright © 2016 Transit Wise. All rights reserved.
//

import UIKit
import RealmSwift

class OptionsViewController: UIViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var optionsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let realmHelper =  RealmHelper()
    var agencies: [Agency]?
    var links: [String] = ["Rate us on the App Store", "Send Feedback", "Follow @transitwise", "Like TransitWise on Facebook", "Share"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        agencies = realmHelper.getAgencies()
        
        // setup table view 
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clearColor()
        
    }
    
//    override func viewDidAppear(animated: Bool) {
//        agencies = realmHelper.getAgencies()
//    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(optionsSegmentedControl.selectedSegmentIndex == 0){
            return agencies!.count
        }
        else{
            return links.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(optionsSegmentedControl.selectedSegmentIndex == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("agencyOptionCell", forIndexPath: indexPath) as! AgencyOptionCell
            cell.agencyNameLabel.text = agencies![indexPath.row].name
            cell.id = agencies![indexPath.row]._id
            cell.agencySelectedSwitch.setOn(agencies![indexPath.row].filter_state!.boolValue, animated: false)
            cell.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("linkCell", forIndexPath: indexPath) as! LinkCell
            cell.linkNameLabel.text = links[indexPath.row]
            cell.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
            return cell
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    @IBAction func doneButtonTap(sender: AnyObject) {
    }
    
    @IBAction func segmentChange(sender: AnyObject) {
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        if(optionsSegmentedControl.selectedSegmentIndex == 0){
            headerLabel.hidden = false
        }
        else{
            headerLabel.hidden = true
        }
    }
    
}

