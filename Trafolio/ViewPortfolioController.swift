import UIKit
import MapKit
import AFNetworking

class ViewPortfolioController: UIViewController, UIScrollViewDelegate, MKMapViewDelegate {
	@IBOutlet weak var editButton: UIBarButtonItem!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var photoDescriptionLabel: UILabel!

	var portfolio: Portfolio!
	private var scrollImageViews: [UIImageView] = []
	private var descriptions: [String?] = []
	private var annotations: [MKAnnotation] = []

	let PORTFOLIO_GET_PATH = "/getimages.php"

	private var feedDone = false

	private var currentShowIndex: Int = -1 {
		didSet{
			if self.currentShowIndex != oldValue && self.feedDone {
				self.photoDescriptionLabel.text = self.descriptions[self.currentShowIndex]
				self.mapZoomToAnnotation(self.currentShowIndex)
			}
		}
	}

	private var manager: AFHTTPSessionManager {
		let manager = (UIApplication.sharedApplication().delegate as! AppDelegate).httpManager
		manager.requestSerializer.setValue(AUTH_CODE, forHTTPHeaderField: "auth_code")
		return manager
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.mapView.delegate = self
		self.scrollView.delegate = self
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		if self.portfolio.username == ConnectedUser.sharedInstance().username! {
			self.editButton.enabled = true
		} else {
			self.editButton.enabled = false
		}
		self.setupScrollView()
		let params = ["username": self.portfolio.username,
					  "portfolio": self.portfolio.name]
		self.manager.GET(SERVER_URL + PORTFOLIO_GET_PATH, parameters: params, success: { (dataTask, response) -> Void in
			if let data = response {
				let result = PortfolioMapManager.getNodesFromJSON(data)
				self.portfolio.num_pic = result.count
				self.feedImages(result)
			}
			}) { (dataTask, error) -> Void in
				NSLog("Get Portfolio failed, error \(error.localizedDescription)")
		}
		NSLog("Update Portfolio")
	}
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
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
		if self.scrollImageViews.count == self.portfolio.num_pic {
			return
		} else {
			for view in self.scrollImageViews {
				view.removeFromSuperview()
			}
		}
		self.scrollView.pagingEnabled = true
		self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * CGFloat(self.portfolio.num_pic), self.scrollView.frame.size.height)
		self.scrollView.directionalLockEnabled = true

		for index in 0..<self.portfolio.num_pic {
			let imageView = UIImageView()
			self.scrollImageViews.append(imageView)
			imageView.contentMode = .ScaleAspectFit
			imageView.backgroundColor = UIColor.clearColor()

			imageView.frame = CGRectMake(CGFloat(index) * self.scrollView.bounds.width, 0, self.scrollView.bounds.width, self.scrollView.bounds.height)
			self.scrollView.addSubview(imageView)

//			var mConstraints:[NSLayoutConstraint] = []
//			if index == 0 {
//				mConstraints.append(NSLayoutConstraint(item: imageView, attribute: .Leading, relatedBy: .Equal, toItem: self.scrollView, attribute: .Leading, multiplier: 1, constant: 0))
//			} else {
//				mConstraints.append(NSLayoutConstraint(item: imageView, attribute: .Leading, relatedBy: .Equal, toItem: self.scrollImageViews[index-1], attribute: .Trailing, multiplier: 1, constant: 0))
//			}
//			mConstraints.append(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: self.scrollView, attribute: .Height, multiplier: 1, constant: 0))
//			mConstraints.append(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: self.scrollView, attribute: .Width, multiplier: 1, constant: 0))
//			mConstraints.append(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self.scrollView, attribute: .CenterY, multiplier: 1, constant: 0))
//			imageView.addConstraints(mConstraints)
		}
	}

	private func feedImages(nodes: [PortfolioNode]) {
		self.mapView.removeAnnotations(self.mapView.annotations)
		self.descriptions = []
		self.annotations = []

		for index in 0..<nodes.count {
			print(nodes[index].image!)
			self.scrollImageViews[index].sd_setImageWithURL(nodes[index].image!)
			self.descriptions.append(nodes[index].description)
			let annotation = TFPointAnnotation(type: .Show)
			annotation.node = nodes[index]
			annotation.coordinate = nodes[index].location.coordinate
			self.annotations.append(annotation)
			self.mapView.addAnnotation(annotation)
		}
		self.feedDone = true
		if nodes.count > 0 {
			let sortedNode = nodes.sort { $0 < $1 }
			var sortedCoords = sortedNode.map{ $0.location.coordinate }
			if sortedCoords.count > 1 {
				let line = MKGeodesicPolyline(coordinates: &sortedCoords, count: sortedCoords.count)
				self.mapView.addOverlay(line)
			}
			self.currentShowIndex = 0
		}
	}

	// MARK: MapView Delegate
	private let RegionRadius: CLLocationDistance = 1000

	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		if let tfAnnotation = annotation as? TFPointAnnotation {
			let annotationView = TFAnnotationView(annotation: tfAnnotation, reuseIdentifier: "ShowPhotoPin")
			annotationView.translatesAutoresizingMaskIntoConstraints = false
			annotationView.imageView.sd_setImageWithURL(tfAnnotation.node!.image!)
			return annotationView
		}
		return MKAnnotationView()
	}

	func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.7)
		renderer.lineWidth = 4
		renderer.lineDashPattern = [2, 7]
		return renderer
	}

	private func mapZoomToAnnotation(index: Int) {
		let coordinate = self.annotations[index].coordinate
		self.centerMapOnLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), animated: true)
	}

	private func centerMapOnLocation(location: CLLocation, animated: Bool) {
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, RegionRadius * 2.0, RegionRadius * 2.0)
		self.mapView.setRegion(coordinateRegion, animated: animated)
	}



	// MARK: ScrollView Delegate

	func scrollViewDidScroll(scrollView: UIScrollView) {
		let index = Int(floor(scrollView.contentOffset.x / scrollView.bounds.width))
		self.currentShowIndex = index
	}
}