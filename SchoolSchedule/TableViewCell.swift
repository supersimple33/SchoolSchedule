//
//  TableViewCell.swift
//  SchoolSchedule
//
//  Created by Addison Hanrattie on 2/7/18.
//  Copyright © 2018 Addison Hanrattie. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    var hour: Int? = nil
    var minute: Int? = nil
    var classnumber: Int? = nil
    var day: Int! = nil
    @IBOutlet weak var hL1: UILabel!
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
