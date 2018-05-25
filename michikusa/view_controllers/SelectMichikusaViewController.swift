import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

class SelectMichikusaViewController: UIViewController {
    
    @IBOutlet weak var michikusaSpot: PickerKeyboard!
    @IBOutlet weak var mapView: GMSMapView!
    var previousCamera: GMSCameraPosition?
    var previousMarker: GMSMarker?
    var michikusaRange: Int?
    var data:[String] = ["hoge", "hage"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.michikusaSpot.addData(d: self.data)
        drawMap()
        //GooglePlace検索＆マップ表示
        print ("positon:\(self.previousMarker!.position)")
        
        getPlaceList(location:self.previousMarker!.position, range:michikusaRange! ,mapView:mapView)
        //getPlaceList(mapView:mapView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func drawMap() {
        if self.previousMarker != nil {
            self.previousMarker!.map = self.mapView
        }
    }
    
    
    func getPlaceList (location: CLLocationCoordinate2D, range:Int, mapView:GMSMapView) {
        let centerPoint = "\(location.latitude),\(location.longitude)"
        let range = 1000 * range
        let type = "cafe"
        let key = "AIzaSyB2VMdWQslynrxRgCA3vpWQAjqxvkKmCWk"

        let url = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        Alamofire.request(url,parameters:["key":key, "location":centerPoint, "radius":range,"type":type]).responseJSON { response in
            let json = JSON(response.result.value!)
            json["results"].forEach{(_,place) in
                let name = place["name"].string!
                print (name)
                let placeLat = place["geometry"]["location"]["lat"].doubleValue
                let placeLng = place["geometry"]["location"]["lng"].doubleValue
                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: placeLat, longitude: placeLng))
                marker.map = mapView
            }
        }
    }
}


