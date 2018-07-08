import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON
import Material

class ConfirmMichikusaViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    var previousCamera: GMSCameraPosition?
    var michikusaRange: Int?
    var michikusaType: String?
    var cog2d: CLLocationCoordinate2D?
    var selectedMarker: GMSMarker?
    var currentLocation: CLLocationCoordinate2D?
    var destLocation: CLLocationCoordinate2D!
    var polyline: GMSPolyline?
    var mutablePath: GMSMutablePath?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let tmp = self.previousCamera {
            self.mapView.camera = tmp
        }
        
        drawMap()
        
        self.mapView.settings.myLocationButton = true
        self.mapView.isMyLocationEnabled = true        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        drawMap()
    }
    
    func drawMap() {
        if self.selectedMarker != nil {
            self.selectedMarker!.map = self.mapView
        }
        
        let dstMarker = GMSMarker(position: destLocation)
        dstMarker.map = self.mapView
        
        drawPath(startLocation: currentLocation!, endLocation: destLocation)
    }

    func drawPath(startLocation: CLLocationCoordinate2D, endLocation: CLLocationCoordinate2D) {
        let origin = "\(startLocation.latitude),\(startLocation.longitude)"
        let destination = "\(endLocation.latitude),\(endLocation.longitude)"
        let mediumPoint = CLLocationCoordinate2D(latitude: (startLocation.latitude + endLocation.latitude) / 2,
                                                 longitude: (startLocation.longitude + endLocation.longitude) / 2)
        var url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        
        if selectedMarker != nil {
            let wayspoint = "\(selectedMarker!.position.latitude),\(selectedMarker!.position.longitude)"
            url = "\(url)&waypoints=\(wayspoint)"
            print(url)
        }

        Alamofire.request(url).responseJSON { response in
            let json = try! JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            print("routes count: \(routes.count)")
            var durationText: String = ""
            var distanceText: String = ""
            var distance: Double = 0
            var duration: Double = 0
            
            for route in routes {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath(fromEncodedPath: points!)
                
                self.mutablePath = GMSMutablePath(path: path!)
                
                self.polyline = GMSPolyline(path: path)
                let legs = route["legs"].arrayValue.last
                distance = (legs!["distance"].dictionary?["value"]?.doubleValue)!
                duration = (legs!["duration"].dictionary?["value"]?.doubleValue)!
                durationText = (legs!["duration"].dictionary?["text"]?.stringValue)!
                distanceText = (legs!["distance"].dictionary?["text"]?.stringValue)!
                
                self.polyline?.strokeWidth = 4
                self.polyline?.strokeColor = Color.indigo.darken1
                self.polyline?.title = "所要時間 \(durationText), 距離: \(distanceText)"
                self.polyline?.isTappable = true
                self.polyline?.map = self.mapView
            }
            
            let camera = GMSCameraPosition.camera(withTarget: mediumPoint, zoom: Float(self.getAppreciateZoomSize(distance: distance)))
            self.mapView.camera = camera
        }
    }
    
    @IBAction func move2GoogleMapApp(_ sender: UIButton) {
        let testURL = URL(string: "https://")!
        let origin = "\(currentLocation!.latitude),\(currentLocation!.longitude)"
        let destination = "\(destLocation.latitude),\(destLocation.longitude)"
        
        if UIApplication.shared.canOpenURL(testURL) {
            var directionsRequest = "https://www.google.com/maps/dir/?api=1&origin=\(origin)&destination=\(destination)&travelmode=driving&"
            if selectedMarker != nil {
                let wayspoint = "\(selectedMarker!.position.latitude),\(selectedMarker!.position.longitude)"
                directionsRequest = "\(directionsRequest)&waypoints=\(wayspoint)"
                print(directionsRequest)
            }
            
            let directionsURL = URL(string: directionsRequest)!
            UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
        } else {
            NSLog("Can't use comgooglemaps-x-callback:// on this device.")
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
}
