//
//  ImageViewCell.swift
//  VirtualTourist
//
//  Created by Malrasheed on 11/01/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
class ImageViewCell: UICollectionViewCell{
    static let identifier = "ImageCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}
