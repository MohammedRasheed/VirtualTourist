//
//  LocationAlbumViewController.swift
//  VirtualTourist
//
//  Created by Malrasheed on 03/01/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class AlbumViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var location: Location!
    var dataController: DataController!
    var images = [Image]()
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let longitude = location.value(forKey: "longitude") as! Double
        let latitude = location.value(forKey: "latitude") as! Double
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0, longitudeDelta: 0.0))
        self.mapView.setRegion(region, animated: true)
        self.mapView.addAnnotation(annotation)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.images = location.images?.allObjects as! [Image]
        if images.count == 0{
            requestImages()
        }
            
        collectionView.reloadData()
        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    func requestImages(){
        // get response number of pages
        
        var url = VTClient.Endpoints.fetchRequest.stringValue + "&lat=\(location.latitude)&lon=\(location.longitude)"
       
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            guard let data = data, error == nil else { print(error?.localizedDescription); return }
            
            let decoder = JSONDecoder()
            let photosParser = try? decoder.decode(PhotosParser.self, from: data)
            let maxNumber = photosParser?.photos.pages
            let randomPage = Int(arc4random_uniform(UInt32(maxNumber as! Int))) + 1
            url = url + "&page=\(randomPage)"
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
                guard let data = data, error == nil else { print(error?.localizedDescription); return }
                
                let decoder = JSONDecoder()
                let photosParser = try? decoder.decode(PhotosParser.self, from: data)
                for photo in (photosParser?.photos.photo)!{
                    if photo.url != nil{
                        let url = URL(string: photo.url!)
                        let data = try? Data(contentsOf: url!)
                        let image = Image(context: self.dataController.viewContext)
                        image.location = self.location
                        image.photo = data!
                        self.images.append(image)
                        self.location.addToImages(image)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
            task.resume()
        }
        task.resume()
        collectionView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        try? dataController.viewContext.save()
        super.viewWillDisappear(true)
    }
    
    @IBAction func addMeme(_ sender: Any) {
        let createMemeViewController = self.storyboard!.instantiateViewController(withIdentifier: "CreateMemeViewController") as! CreateMemeViewController
        createMemeViewController.dataController = self.dataController
        createMemeViewController.location = self.location
        self.navigationController!.pushViewController(createMemeViewController, animated: true)
    }
    
    @IBAction func newCollection(_ sender: Any) {
        self.location.images = nil
        let oldImages = images
        for image in oldImages{
            dataController.viewContext.delete(image)
        }
        images = [Image]()
        requestImages()
    }
}
