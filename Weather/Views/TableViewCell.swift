//
//  TableViewCell.swift
//  Weather
//
//  Created by Subheksha Gautam on 13/7/2022.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        selectedBackgroundView = {
                        let view = UIView()
            view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                        return view
        }()
    }


    }
    

