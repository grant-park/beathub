//
//  RecordingCollectionViewCell.swift
//  YHack
//
//  Created by Grant Hyun Park on 11/6/15.
//  Copyright © 2015 Grant Hyun Park. All rights reserved.
//

import UIKit

class RecordingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var label: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = UIView(frame:self.frame)
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        view.layer.borderColor = UIColor.whiteColor().CGColor
        view.layer.borderWidth = 4
        self.selectedBackgroundView = view
    }

}
