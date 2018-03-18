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
        
        // mapview の描画サイズ
        let width: CGFloat = self.view.frame.maxX
        let height: CGFloat = self.view.frame.maxY
        
        let zoom: Float = 15
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoom)
        
        // mapview の作成
        mapView = GMSMapView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        mapView.camera = camera
        
        // mapviewの設定
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        
        // marker 1
        let marker1: GMSMarker = GMSMarker()
        let marker1_lat = latitude + 0.001
        let marker1_long = longitude + 0.001
        
        marker1.position = CLLocationCoordinate2D(latitude: marker1_lat, longitude: marker1_long)
        marker1.title = "Marker 1"
        marker1.snippet = "Marker 1"
        marker1.map = mapView
        
        // marker 2
        let marker2: GMSMarker = GMSMarker()
        let marker2_lat = latitude - 0.001
        let marker2_long = longitude - 0.001
        
        marker2.position = CLLocationCoordinate2D(latitude: marker2_lat, longitude: marker2_long)
        marker2.title = "Marker2"
        marker2.snippet = "Marker2"
        marker2.map = mapView
        
        // marker2 を中心とした半径500mの円
        let circleCenter = CLLocationCoordinate2DMake(marker2_lat, marker2_long)
        let circle = GMSCircle(position: circleCenter, radius: 500)
        circle.fillColor = UIColor(red: 0, green: 0.1, blue: 0.11, alpha: 0.55)
        circle.strokeColor = UIColor.blue
        circle.map = mapView
        
        // marker1 と marker2 を繋ぐ直線
        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2DMake(marker1_lat, marker1_long))
        path.add(CLLocationCoordinate2DMake(marker2_lat, marker2_long))
        
        let polyLine = GMSPolyline(path: path)
        polyLine.strokeWidth = 3.0
        polyLine.map = mapView

        self.view.addSubview(mapView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

