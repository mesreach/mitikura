import UIKit
import GoogleMaps

class SetRangeViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    let latitude: CLLocationDegrees = 35.531064
    let longitude: CLLocationDegrees = 139.684389

    var previousPolyLine: GMSPolyline?
    var previousCamera: GMSCameraPosition?
    var previousMarker: GMSMarker?
    
    @IBOutlet weak var picker_km: PickerKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker_km.addData(d: ["1", "2", "3"])
        
        if let tmp = self.previousCamera {
            self.mapView.camera = tmp
        }
        if self.previousPolyLine != nil {
            self.previousPolyLine!.map = self.mapView
        }
        
        if self.previousMarker != nil {
            self.previousMarker!.map = self.mapView
        }
        self.mapView.settings.myLocationButton = true
        self.mapView.isMyLocationEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        if self.previousPolyLine != nil {
            self.previousPolyLine!.map = self.mapView
        }
        
        if self.previousMarker != nil {
            self.previousMarker!.map = self.mapView
        }
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func goNext_(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "selectMichikusaView")
        self.present(next, animated: true, completion: nil)
    }
}
