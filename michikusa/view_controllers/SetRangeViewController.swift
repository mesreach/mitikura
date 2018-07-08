import UIKit
import GoogleMaps

class SetRangeViewController: UIViewController {

    
    @IBOutlet weak var michikusaType: PickerKeyboard!
    @IBOutlet weak var mapView: GMSMapView!
    let latitude: CLLocationDegrees = 35.531064
    let longitude: CLLocationDegrees = 139.684389

    var previousPolyLine: GMSPolyline?
    var previousCamera: GMSCameraPosition?
    var previousMarker: GMSMarker?
    var previousLimitPolyLine: GMSPolyline?
    var previousCOG2d: CLLocationCoordinate2D?
    var previousCOGRadius: Int?
    var typeList:[String] = ["cafe","store","bar","park","museum"]
    var currentLocation: CLLocationCoordinate2D?
    var destLocation: CLLocationCoordinate2D!

    @IBOutlet weak var picker_km: PickerKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.michikusaType.addData(d: self.typeList)
        self.michikusaType.textStore = "cafe"
        
        picker_km.addData(d: Array(1...10).map({ "\($0)" }))
        picker_km.textStore = "1"
        picker_km.button.addTarget(self, action: #selector(didTapDone(sender:)), for: .touchUpInside)
        
        if let tmp = self.previousCamera {
            self.mapView.camera = tmp
        }
        
        drawMap()
        
        self.mapView.settings.myLocationButton = true
        self.mapView.isMyLocationEnabled = true
        
        drawMichikusaRange(Int(picker_km.textStore)! * 1000)
    }
    
    @objc func didTapDone(sender: Any) {
        drawMichikusaRange(Int(picker_km.textStore)! * 1000)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        drawMap()
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func goNext_(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "selectMichikusaView") as! SelectMichikusaViewController
        //次画面への引数
        next.michikusaRange = Int(picker_km.textStore)!
        next.previousMarker = self.previousMarker
        next.previousCamera = self.mapView.camera
        next.previousLimitPolyLine = self.previousLimitPolyLine
        next.previousPolyLine = self.previousPolyLine
        next.michikusaType = self.michikusaType.textStore
        next.cog2d = self.previousCOG2d
        next.previousCOGRadius = self.previousCOGRadius
        next.currentLocation = self.currentLocation
        next.destLocation = self.destLocation
        self.present(next, animated: true, completion: nil)
        
    }
    
    func drawMap() {
        if self.previousPolyLine != nil {
            self.previousPolyLine!.map = self.mapView
        }
        
        if self.previousMarker != nil {
            self.previousMarker!.map = self.mapView
        }
        
        if self.previousLimitPolyLine != nil {
            self.previousLimitPolyLine!.map = self.mapView
        }
    }
    
    func drawMichikusaRange(_ range_m_radius: Int) {
        self.mapView.clear()
        drawMap()

        let c: GMSCircle = GMSCircle(position: self.previousCOG2d!, radius: CLLocationDistance(self.previousCOGRadius! + range_m_radius))
        c.map = self.mapView
        c.fillColor = UIColor.red.withAlphaComponent(0.1)
        c.strokeColor = UIColor.red.withAlphaComponent(0.1)
    }
}
