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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.camera = previousCamera!

        //GooglePlace検索＆マップ表示
        getPlaceList(location:self.previousMarker!.position, range:michikusaRange! ,type:michikusaType! ,mapView:mapView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getPlaceList (location: CLLocationCoordinate2D, range:Int, type:String,mapView:GMSMapView) {
        let centerPoint = "\(location.latitude),\(location.longitude)"
        let range:Double = Double(1000 * range)
        let key = "AIzaSyB2VMdWQslynrxRgCA3vpWQAjqxvkKmCWk"
        let url = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        
        Alamofire.request(url,parameters:["key":key, "location":centerPoint, "radius":range, "type":type]).responseJSON { response in
            let json = JSON(response.result.value!)
            json["results"].forEach{(_,place) in
                let placeLat = place["geometry"]["location"]["lat"].doubleValue
                let placeLng = place["geometry"]["location"]["lng"].doubleValue
                let marker   = GMSMarker(position: CLLocationCoordinate2D(latitude: placeLat, longitude: placeLng))
                marker.title   = place["name"].string
                marker.snippet = place["formatted_address"].string
                marker.map     = mapView
            }
            let camera = GMSCameraPosition.camera(withTarget: location, zoom: Float(self.getAppreciateZoomSize(distance: range)))
            self.mapView.camera = camera
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
