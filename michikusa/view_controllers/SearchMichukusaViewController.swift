import UIKit
import GoogleMaps

class SearchMichukusaViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    var previousPolyLine: GMSPolyline?
    var previousCamera: GMSCameraPosition?
    var previousMarker: GMSMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goNext_(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "RangeAndGenre") as! RangeAndGenreViewController
        let pl = self.previousPolyLine
        pl?.map = nil
        next.previousPolyLine = pl
        next.previousMarker = self.previousMarker
        next.previousCamera = self.mapView.camera
        self.present(next, animated: true, completion: nil)
    }
}
