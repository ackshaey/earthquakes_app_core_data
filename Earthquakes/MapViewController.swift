//
//  MapViewController.swift
//  Earthquakes
//
//  Created by Ackshaey Singh on 3/26/15.
//  Copyright (c) 2015 Ackshaey Singh. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var mapV: MKMapView!
    
    // This will be set from table tap
    var quake: Quake?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let latitude = self.quake!.location.latitude.doubleValue
        let longitude = self.quake!.location.longitude.doubleValue
        let titleLocation = self.quake!.location.locationName
        let subTitle = "Magnitude \(self.quake!.quakeMagnitude)"
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegionMakeWithDistance(center, 1000000, 1000000)
        self.mapV.setRegion(region, animated: true)
        
        let annotation = Annotation(coordinate: center, title: titleLocation, subTitle: subTitle)
        
        self.mapV.addAnnotation(annotation)
        
        
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var pin = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        }
        
        (pin as MKPinAnnotationView).animatesDrop = true
        (pin as MKPinAnnotationView).canShowCallout = true
        (pin as MKPinAnnotationView).enabled = true
        (pin as MKPinAnnotationView).pinColor = MKPinAnnotationColor.Purple
        return pin
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
