import UIKit
import GoogleMaps

class RangeAndGenreViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    let latitude: CLLocationDegrees = 35.531064
    let longitude: CLLocationDegrees = 139.684389
    
    @IBOutlet weak var picker_genre: PickerKeyboard!
    @IBOutlet weak var picker_km: PickerKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker_genre.addData(d: ["hoge", "hage"])
        picker_km.addData(d: ["1", "2", "3"])
        
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
        let next = storyboard!.instantiateViewController(withIdentifier: "selectMichikusaView")
        self.present(next, animated: true, completion: nil)
    }
}
