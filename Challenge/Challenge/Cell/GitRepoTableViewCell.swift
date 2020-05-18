//
//  GitRepoTableViewCell.swift
//  Challenge
//
//  Created by Suraj Kodre on 15/05/20.
//  Copyright © 2020 Suraj Kodre. All rights reserved.
//

import UIKit

class GitRepoTableViewCell: UITableViewCell {

    @IBOutlet weak var repoScoreLabel: UILabel!
    @IBOutlet weak var repoTitleLabel: UILabel!
    @IBOutlet weak var repoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
