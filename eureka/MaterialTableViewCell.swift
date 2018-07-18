//
//  MaterialTableViewCell.swift
//  eureka
//
//  Created by Yuya Imoto on 2018/07/17.
//  Copyright © 2018年 Yuya Imoto. All rights reserved.
//

import UIKit

class MaterialTableViewCell: UITableViewCell {

    @IBOutlet weak var materialLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
