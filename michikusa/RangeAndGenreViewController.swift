//
// Copyright (c) 2018年, 玉越敬典.
// All rights reserved.
//


import UIKit
import GoogleMaps

class RangeAndGenreViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var picker01: UIPickerView!
    @IBOutlet weak var picker02: UIPickerView!

    var picker01_data:[String] = [String]()
    var picker02_data:[String] = [String]()
    
    var mapView : GMSMapView!
    let latitude: CLLocationDegrees = 35.531064
    let longitude: CLLocationDegrees = 139.684389
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPickerData()
        
        self.picker01.selectRow(0, inComponent: 0, animated: true)
        self.picker02.selectRow(0, inComponent: 0, animated: true)
        self.picker01.delegate = self
        self.picker02.delegate = self
        
        self.picker01.showsSelectionIndicator = true;
        self.picker02.showsSelectionIndicator = true;
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
    
    func initPickerData() {
        self.picker01.tag = 1
        self.picker02.tag = 2
        self.picker01_data = ["1", "2", "3"]
        self.picker02_data = ["hoge", "hoge2", "hoge3"]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return picker01_data.count
        } else {
            return picker02_data.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return picker01_data[row]
        } else {
            return picker02_data[row]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goNext_(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "RangeAndGenre")
        self.present(next, animated: true, completion: nil)
    }
    
    
}


