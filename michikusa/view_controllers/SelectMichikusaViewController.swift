import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

class SelectMichikusaViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    var previousCamera: GMSCameraPosition?
    var previousMarker: GMSMarker?
    var michikusaRange: Int?
    var michikusaType: String?
    var previousPolyLine: GMSPolyline?
    var previousLimitPolyLine: GMSPolyline?
    var previousCOGRadius: Int?
    var cog2d: CLLocationCoordinate2D?
    var selectedMarker: GMSMarker?
    var defaultIcon: UIImage?
    var currentLocation: CLLocationCoordinate2D?
    var destLocation: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self

        if let tmp = self.previousCamera {
            self.mapView.camera = tmp
        }
        
        drawMap()
        
        self.mapView.settings.myLocationButton = true
        self.mapView.isMyLocationEnabled = true
        
        //GooglePlace検索＆マップ表示
        let range = self.michikusaRange! * 1000
        let radius = self.previousCOGRadius! + range
        getPlaceList(location: self.cog2d!, radius: radius, range: range, type: michikusaType!, mapView: mapView)
        
        let c: GMSCircle = GMSCircle(position: self.cog2d!, radius: CLLocationDistance(radius))
        c.map = self.mapView
        c.fillColor = UIColor.red.withAlphaComponent(0.1)
        c.strokeColor = UIColor.red.withAlphaComponent(0.1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func goNext_(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "confirmMichikusaView") as! ConfirmMichikusaViewController
        next.previousCamera = self.mapView.camera
        next.michikusaType = self.michikusaType
        next.selectedMarker = self.selectedMarker
        next.currentLocation = self.currentLocation
        next.destLocation = self.destLocation
        self.present(next, animated: true, completion: nil)
    }
    
    func getPlaceList (location: CLLocationCoordinate2D, radius: Int, range: Int, type: String, mapView: GMSMapView) {
        let centerPoint = "\(location.latitude),\(location.longitude)"
        let radius: Double = Double(radius)
        let key = "AIzaSyB2VMdWQslynrxRgCA3vpWQAjqxvkKmCWk"
        let url = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        
        Alamofire.request(url,parameters:["key":key, "location": centerPoint, "radius": radius, "type":type]).responseJSON { response in
            let json = JSON(response.result.value!)
            json["results"].forEach{(_,place) in
                let placeLat = place["geometry"]["location"]["lat"].doubleValue
                let placeLng = place["geometry"]["location"]["lng"].doubleValue
                let marker   = GMSMarker(position: CLLocationCoordinate2D(latitude: placeLat, longitude: placeLng))
                marker.title   = place["name"].string
                marker.snippet = place["formatted_address"].string
                marker.map     = mapView
                
                let isInPath = GMSGeometryIsLocationOnPathTolerance(marker.position, self.previousLimitPolyLine!.path!, false, CLLocationDistance(range))
                
                if !isInPath {
                    marker.icon = GMSMarker.markerImage(with: .black)
                }
            }
        }
    }
    
    func getAppreciateZoomSize(distance: Double) -> Int {
        print(distance)
        switch distance {
        case 1..<1000:
            return 16
        case 1000..<5000:
            return 14
        case 5000..<10000:
            return 13
        case 10000..<20000:
            return 12
        case 20000..<50000:
            return 7
        case 50000..<1000000000000:
            return 7
        default:
            return 10
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        drawMap()
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
}

extension SelectMichikusaViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if self.selectedMarker != nil {
            self.selectedMarker?.icon = self.defaultIcon
        }
        self.selectedMarker = marker
        self.defaultIcon = self.selectedMarker?.icon

        marker.icon = GMSMarker.markerImage(with: .blue)
        return false
    }
}
