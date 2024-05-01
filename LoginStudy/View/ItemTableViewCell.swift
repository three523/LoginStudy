//
//  ItemTableViewCell.swift
//  LoginStudy
//
//  Created by 김도현 on 2024/05/01.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLable: UILabel!
    @IBOutlet weak var itemPriceLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
