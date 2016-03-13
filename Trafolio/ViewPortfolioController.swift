import UIKit
import MapKit
import AFNetworking

class ViewPortfolioController: UIViewController, UIScrollViewDelegate, MKMapViewDelegate {
	@IBOutlet weak var editButton: UIBarButtonItem!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var photoDescriptionLabel: UILabel!

	var portfolio: Portfolio!

	let IMAGES_PATH = "/getimages.php"

	private var manager: AFHTTPSessionManager {
		let manager = (UIApplication.sharedApplication().delegate as! AppDelegate).httpManager
		manager.requestSerializer.setValue(AUTH_CODE, forHTTPHeaderField: "auth_code")
		return manager
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		if self.portfolio.username == ConnectedUser.sharedInstance().username! {
			self.editButton.enabled = true
		} else {
			self.editButton.enabled = false
		}

		
		self.setupScrollView()
	}

	@IBAction func editAction(sender: AnyObject) {
		self.performSegueWithIdentifier("EditFromView", sender: self)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let identifier = segue.identifier {
			if identifier == "EditFromView" {
				if let editVC = segue.destinationViewController as? EditPortfolioController {
					editVC.editingPortfolioName = self.portfolio.name
					editVC.title = "Editing " + self.portfolio.name
				}
			}
		}
	}

	private func setupScrollView() {

	}
}