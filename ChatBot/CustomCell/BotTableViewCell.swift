//
//  BotTableViewCell.swift
//  ChatBot
//
//  Created by Riddhi Makwana on 01/09/21.
//

import UIKit

class BotTableViewCell: UITableViewCell {
    @IBOutlet weak var imgBackground : UIImageView!
    @IBOutlet weak var lblMessage : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
