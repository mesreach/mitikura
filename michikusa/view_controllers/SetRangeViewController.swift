import UIKit
import GoogleMaps

class SetRangeViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    let latitude: CLLocationDegrees = 35.531064
    let longitude: CLLocationDegrees = 139.684389

    var previousPolyLine: GMSPolyline?
    var previousCamera: GMSCameraPosition?
    var previousMarker: GMSMarker?
    var previousLimitPolyLine: GMSPolyline?
    
    @IBOutlet weak var picker_km: PickerKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        print ("Picker_km:\(Int(picker_km.textStore)!)")
        next.michikusaRange = Int(picker_km.textStore)!
        print ("michikusaRange:\(next.michikusaRange!)")
        next.previousMarker = self.previousMarker
        next.previousCamera = self.mapView.camera
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
        var p: CLLocationCoordinate2D
        let count = (self.previousLimitPolyLine?.path?.count())!
        self.mapView.clear()
        drawMap()

        let v = UInt(self.picker_km.textStore)! * 3
        for i in 0..<count {
            if i % v == 0 {
                p = (self.previousLimitPolyLine?.path?.coordinate(at: i))!
                let c = GMSCircle(position: p, radius: CLLocationDistance(range_m_radius))
                c.fillColor = UIColor.red.withAlphaComponent(0.1)
                c.strokeColor = UIColor.red.withAlphaComponent(0.1)
                c.map = self.mapView
            }
        }
    }
}
