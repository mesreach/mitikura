//
//  ViewController.swift
//  michikusa
//
//  Created by 玉越敬典 on 2018/03/18.
//  Copyright © 2018年 玉越敬典. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

    var mapView : GMSMapView!
    let latitude: CLLocationDegrees = 35.531064
    let longitude: CLLocationDegrees = 139.684389
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let zoom: Float = 15
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoom)
        
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.view = mapView
        
        let marker: GMSMarker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = "Test"
        marker.snippet = "Tesst"
        marker.map = mapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

