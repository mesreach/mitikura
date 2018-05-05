import UIKit
import GoogleMaps

class SearchMichukusaViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    let latitude: CLLocationDegrees = 35.531064
    let longitude: CLLocationDegrees = 139.684389
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let zoom: Float = 15
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoom)
        mapView.camera = camera
        
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goNext_(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "RangeAndGenre")
        self.present(next, animated: true, completion: nil)
    }
}
