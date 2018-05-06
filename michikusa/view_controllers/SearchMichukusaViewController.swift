import UIKit
import GoogleMaps

class SearchMichukusaViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goNext_(_ sender: UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "RangeAndGenre")
        self.present(next, animated: true, completion: nil)
    }
}
