//
//  LandingMapViewController.swift
//  VirtualTourist
//
//  Created by Malrasheed on 03/01/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var dataController: DataController!
    var locationsArray = [Location]()
    static var deleteMode: Bool = false
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var deleteModeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteModeLabel.isHidden = true
        deleteModeLabel.layer.zPosition = mapView.layer.zPosition + 1
        mapView.delegate = self
        let selectedLocation = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(selectedLocation:)))
        mapView.addGestureRecognizer(selectedLocation)
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        
        if let locations = try? dataController.viewContext.fetch(fetchRequest) {
            var annotations = [MKPointAnnotation]()
            for location in locations {
                locationsArray.append(location)
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: location.value(forKey: "latitude") as! Double, longitude: location.value(forKey: "longitude") as! Double)
                annotations.append(annotation)
            }
            mapView.addAnnotations(annotations)
        }
    }
    @objc func getLocation(selectedLocation: UIGestureRecognizer) {
        if !MapViewController.deleteMode {
            let newLocation = selectedLocation.location(in: mapView)
            let coordinate = mapView.convert(newLocation, toCoordinateFrom: mapView)
            var annotation = MKPointAnnotation()
            if selectedLocation.state == .began {
                annotation.coordinate = coordinate
            
                mapView.addAnnotation(annotation)
            
            } else if selectedLocation.state == .changed {
                annotation.coordinate = coordinate
            } else if selectedLocation.state == .ended {
            
                mapView.addAnnotation(annotation)
                let location = Location(context: dataController.viewContext)
                location.longitude = coordinate.longitude
                location.latitude = coordinate.latitude
                locationsArray.append(location)
                try? self.dataController.viewContext.save()
            }
        }
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
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if MapViewController.deleteMode{
            for (index, location) in locationsArray.enumerated(){
                let latitude: Double =  (view.annotation?.coordinate.latitude)!
                let longitude: Double =  (view.annotation?.coordinate.longitude)!
                if (longitude.isEqual(to: location.value(forKey: "longitude") as! Double)) && (latitude.isEqual(to: location.value(forKey: "latitude") as! Double)) {
                    dataController.viewContext.delete(location)
                    try? dataController.viewContext.save()
                    locationsArray.remove(at: index)
                    mapView.removeAnnotation(view.annotation!)
                    break
                }
            }
        }
        else{
            let albumViewController = self.storyboard!.instantiateViewController(withIdentifier: "AlbumCollectionController") as! AlbumViewController
            for location in locationsArray{
                let latitude: Double =  (view.annotation?.coordinate.latitude)!
                let longitude: Double =  (view.annotation?.coordinate.longitude)!
                if (longitude.isEqual(to: location.value(forKey: "longitude") as! Double)) && (latitude.isEqual(to: location.value(forKey: "latitude") as! Double)) {
                    albumViewController.location = location
                    mapView.deselectAnnotation(view.annotation, animated: true)
                }
            }
            
            albumViewController.dataController = self.dataController
            self.navigationController!.pushViewController(albumViewController, animated: true)
        }
        
    }
    
    @IBAction func deleteMode(_ sender: Any) {
        MapViewController.deleteMode = !MapViewController.deleteMode
        deleteModeLabel.isHidden = !MapViewController.deleteMode
        
    }
    
}
