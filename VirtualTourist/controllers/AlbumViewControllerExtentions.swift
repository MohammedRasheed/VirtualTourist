//
//  MapViewControllerExtentions.swift
//  VirtualTourist
//
//  Created by Malrasheed on 11/01/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import UIKit

extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCell.identifier, for: indexPath) as! ImageViewCell
        cell.imageView?.image = UIImage(data: images[(indexPath).row].photo!)
        cell.activityIndicator?.startAnimating()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataController.viewContext.delete(images[indexPath.row])
        try? self.dataController.viewContext.save()
        images.remove(at: indexPath.row)
        collectionView.reloadData()
        
        
    }
    
}
