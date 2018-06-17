import UIKit
import GoogleMaps

class SearchMichukusaViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startKM: UITextField!
    @IBOutlet weak var endKM: UITextField!
    @IBOutlet weak var startTM: UITextField!
    @IBOutlet weak var endTM: UITextField!
    var previousPolyLine: GMSPolyline?
    var previousCamera: GMSCameraPosition?
    var previousMarker: GMSMarker?
    var previousDestDuration: Double = 0
    var previousDestDistance: Double = 0
    var limitMutablePath: GMSMutablePath?
    var originalMutablePath: GMSMutablePath?
    var limitPolyLine: GMSPolyline?
    var cogRadius: Int?
    let rangeSlider = RangeSlider(frame: CGRect.zero)
    var cog2d: CLLocationCoordinate2D?
    
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

        self.view.addSubview(rangeSlider)
        
        rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
        setKMandTMLabel(rangeSlider)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 20.0
        let width = view.bounds.width - 2.0 * margin
        rangeSlider.frame = CGRect(x: margin, y: self.mapView.frame.origin.y + self.mapView.frame.height + margin,
                                   width: width, height: 31.0)
    }
    
    @objc func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        print("Range slider value changed: (\(rangeSlider.lowerValue) \(rangeSlider.upperValue))")
        setKMandTMLabel(rangeSlider)
    }
    
    func setKMandTMLabel(_ rangeSlider: RangeSlider){
        self.startKM.text = SearchMichikusaDecorator.decorate(self.previousDestDistance * rangeSlider.lowerValue, tp: "km")
        self.endKM.text = SearchMichikusaDecorator.decorate(self.previousDestDistance * rangeSlider.upperValue, tp: "km")
        self.startTM.text = SearchMichikusaDecorator.decorate(self.previousDestDuration * rangeSlider.lowerValue, tp: "tm")
        self.endTM.text = SearchMichikusaDecorator.decorate(self.previousDestDuration * rangeSlider.upperValue, tp: "tm")
        
        let count = Double((self.originalMutablePath?.count())!)
        let lstartno = Int(rangeSlider.lowerValue * count)
        let lendno = Int(rangeSlider.upperValue * count)
        
        self.mapView.clear()
        self.previousMarker!.map = self.mapView
        self.previousPolyLine!.map = self.mapView

        self.limitMutablePath = self.originalMutablePath?.mutableCopy() as? GMSMutablePath
        Array(0..<lstartno).forEach { i in self.limitMutablePath?.removeCoordinate(at: 0) }
        Array((lendno - lstartno)..<(Int(count) - lstartno)).forEach { i in self.limitMutablePath?.removeLastCoordinate() }
        let start2d: CLLocationCoordinate2D = (limitMutablePath?.coordinate(at: 0))!
        let end2d: CLLocationCoordinate2D = (limitMutablePath?.coordinate(at: (limitMutablePath?.count())! - 1))!
        let mid2d: CLLocationCoordinate2D = (limitMutablePath?.coordinate(at: (limitMutablePath?.count())!/2 - 1))!
        
        let cog2d_lat = (start2d.latitude + mid2d.latitude + end2d.latitude) / 3
        let cog2d_long = (start2d.longitude + mid2d.longitude + end2d.longitude) / 3
        self.cog2d = CLLocationCoordinate2D(latitude: cog2d_lat, longitude: cog2d_long)
        
        let arry2d = [start2d, mid2d, end2d]
        let arryDistance = arry2d.map { a  in
            CLLocation.distance(from: a, to: cog2d!)
        }
        print(arryDistance)
        let maxDistance = arryDistance.max()
        print("maxDistance: \(maxDistance)")
        
        self.cogRadius = Int(maxDistance!)
        
        self.limitPolyLine = GMSPolyline(path: self.limitMutablePath)
        self.limitPolyLine?.strokeWidth = 6
        self.limitPolyLine?.strokeColor = UIColor.red

        self.limitPolyLine?.map = self.mapView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.previousPolyLine != nil {
            self.previousPolyLine!.map = self.mapView
        }
        
        if self.previousMarker != nil {
            self.previousMarker!.map = self.mapView
        }
        
        setKMandTMLabel(self.rangeSlider)
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goNext_(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "SetRange") as! SetRangeViewController
        let pl = self.previousPolyLine
        pl?.map = nil
        next.previousPolyLine = pl
        next.previousMarker = self.previousMarker
        next.previousCamera = self.mapView.camera
        next.previousLimitPolyLine = self.limitPolyLine
        next.previousCOG2d = self.cog2d
        next.previousCOGRadius = self.cogRadius
        self.present(next, animated: true, completion: nil)
    }
}

extension CLLocation {
    
    /// Get distance between two points
    ///
    /// - Parameters:
    ///   - from: first point
    ///   - to: second point
    /// - Returns: the distance in meters
    class func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
}
