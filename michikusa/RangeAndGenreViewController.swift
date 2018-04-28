//
// Copyright (c) 2018年, 玉越敬典.
// All rights reserved.
//


import UIKit
import GoogleMaps

class RangeAndGenreViewController: UIViewController {
    var mapView : GMSMapView!
    let latitude: CLLocationDegrees = 35.531064
    let longitude: CLLocationDegrees = 139.684389
    
    @IBOutlet weak var picker_genre: PickerKeyboard!
    @IBOutlet weak var picker_km: PickerKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker_genre.addData(d: ["hoge", "hage"])
        picker_km.addData(d: ["1", "2", "3"])
        
        // mapview の描画サイズ
        let width: CGFloat = self.view.frame.maxX
        let height: CGFloat = self.view.frame.maxY / 2.5
        
        let zoom: Float = 15
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoom)
        
        // mapview の作成
        mapView = GMSMapView(frame: CGRect(x: 0, y: 50, width: width, height: height))
        mapView.camera = camera
        
        // mapviewの設定
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        
        self.view.addSubview(mapView)
        self.view.sendSubview(toBack: mapView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goNext_(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "RangeAndGenre")
        self.present(next, animated: true, completion: nil)
    }
}


