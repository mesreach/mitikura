import UIKit
import GoogleMaps

class NextViewController: UIViewController {
    
    var mapView : GMSMapView!
    let latitude: CLLocationDegrees = 35.531064
    let longitude: CLLocationDegrees = 139.684389
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // mapview の描画サイズ
        let width: CGFloat = self.view.frame.maxX
        let height: CGFloat = self.view.frame.maxY - 300
        
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
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goNext_(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "RangeAndGenre")
        self.present(next, animated: true, completion: nil)
    }

    
}

