//
//  OptionsViewController.swift
//  Transit Wise
//
//  Created by Tyler Hoffman on 2016/01/10.
//  Copyright © 2016 Transit Wise. All rights reserved.
//

import UIKit
class OptionsViewController: UIViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var optionsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var agencies: [String] = ["Gautrain","Reya Vaya","MetroRail","A Re Yeng","Joburg Metrobus"]
    var links: [String] = ["Rate us on the App Store", "Send Feedback", "Follow @transitwise", "Like TransitWise on Facebook", "Share"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        // setup table view 
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clearColor()
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(optionsSegmentedControl.selectedSegmentIndex == 0){
            return agencies.count
        }
        else{
            return links.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(optionsSegmentedControl.selectedSegmentIndex == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("agencyOptionCell", forIndexPath: indexPath) as! AgencyOptionCell
            cell.agencyNameLabel.text = agencies[indexPath.row]
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
