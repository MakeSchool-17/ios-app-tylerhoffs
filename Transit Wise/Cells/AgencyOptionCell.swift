//
//  AgencyOptionCell.swift
//  Transit Wise
//
//  Created by Tyler Hoffman on 2016/01/10.
//  Copyright © 2016 Transit Wise. All rights reserved.
//

import UIKit
import RealmSwift

class AgencyOptionCell: UITableViewCell {

    var id: String?
    let realmHelper = RealmHelper()
    @IBOutlet weak var agencyNameLabel: UILabel!
    @IBOutlet weak var agencySelectedSwitch: UISwitch!
    @IBAction func agencyFilterChange(sender: UISwitch) {
        
        realmHelper.switchAgencyFilterState(id!, state: self.agencySelectedSwitch.on)
        
    }
    
}