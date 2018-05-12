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
    let rangeSlider = RangeSlider(frame: CGRect.zero)
    
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
        print(self.previousDestDistance)
        self.startKM.text = SearchMichikusaDecorator.decorate(self.previousDestDistance * rangeSlider.lowerValue, tp: "km")
        self.endKM.text = SearchMichikusaDecorator.decorate(self.previousDestDistance * rangeSlider.upperValue, tp: "km")
        self.startTM.text = SearchMichikusaDecorator.decorate(self.previousDestDuration * rangeSlider.lowerValue, tp: "tm")
        self.endTM.text = SearchMichikusaDecorator.decorate(self.previousDestDuration * rangeSlider.upperValue, tp: "tm")
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
        let next = storyboard!.instantiateViewController(withIdentifier: "SetRange") as! SetRangeViewController
        let pl = self.previousPolyLine
        pl?.map = nil
        next.previousPolyLine = pl
        next.previousMarker = self.previousMarker
        next.previousCamera = self.mapView.camera
        self.present(next, animated: true, completion: nil)
    }
}
