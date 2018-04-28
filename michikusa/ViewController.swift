//
//  ViewController.swift
//  michikusa
//
//  Created by 玉越敬典 on 2018/03/18.
//  Copyright © 2018年 玉越敬典. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, UIWebViewDelegate {

    //var mapView : GMSMapView!
    var mapView: UIWebView!
    let latitude: CLLocationDegrees = 35.531064
    let longitude: CLLocationDegrees = 139.684389
    var targetURL = Bundle.main.path(forResource: "googlemap_webview", ofType: "html");
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // mapview の描画サイズ
        let width: CGFloat = self.view.frame.maxX
        let height: CGFloat = self.view.frame.maxY - 10
        
        let zoom: Float = 15
        
        //mapView = UIWebView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        mapView = UIWebView()
        mapView.delegate = self
        mapView.frame = self.view.bounds
        loadAddressURL()
        
        //let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoom)
        
        // mapview の作成
        //mapView = GMSMapView(frame: CGRect(x: 0, y: 50, width: width, height: height))
        //mapView.camera = camera
        
        // mapviewの設定
        //mapView.settings.myLocationButton = true
        //mapView.isMyLocationEnabled = true
        
        self.view.addSubview(mapView)
        self.view.sendSubview(toBack: mapView)
    }
    
    func loadAddressURL() {
        let requestURL = NSURL(string: targetURL!)
        let req = NSURLRequest(url: requestURL! as URL)
        self.mapView.loadRequest(req as URLRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack_(_ segue: UIStoryboardSegue) {}
    @IBAction func goNext_(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "nextView")
        self.present(next, animated: true, completion: nil)
    }


}

