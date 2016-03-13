import UIKit
import AFNetworking
import MapKit
import BSImagePicker
import PhotosUI
import SDWebImage

class EditPortfolioController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	var editingPortfolioName: String?

	@IBOutlet weak var mapView: MKMapView!

	private var currentCreateAnnotation: TFPointAnnotation?

	let IMAGE_PATH = "/images.php"
	let PORTFOLIO_GET_PATH = "/getimages.php"

	private var mapTapRecognizer: UIGestureRecognizer!
	private var locationManager = CLLocationManager()

	private var firstTimeOpen = true

	private var manager: AFHTTPSessionManager {
		let manager = (UIApplication.sharedApplication().delegate as! AppDelegate).httpManager
		manager.requestSerializer.setValue(AUTH_CODE, forHTTPHeaderField: "auth_code")
		return manager
	}

	private var imageDownloader = SDWebImageManager.sharedManager()

	private var bufferAsset: PHAsset!
	private var bufferLocation: CLLocation!
	private var bufferAssets: [PHAsset]!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.mapView.delegate = self
		self.mapTapRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("didLongPressed:"))
		self.mapTapRecognizer.delegate = self
		self.locationManager.delegate = self
		self.mapView.addGestureRecognizer(self.mapTapRecognizer)

		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.requestLocation()

		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("uploadsFinished"), name: TrafolioUploadCompletedNotification, object: nil)

		self.uploadsFinished()
	}


	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if self.firstTimeOpen {
			if let loc = self.locationManager.location {
				self.centerMapOnLocation(loc, animated: false)
				self.firstTimeOpen = false
			}
		}
	}

	// MARK: MapView Delegate

	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		if let tfAnnotation = annotation as? TFPointAnnotation {
			if tfAnnotation.type == .Create {
				let customPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "AddPhotoCallout")
				customPinView.pinTintColor = UIColor.redColor()
				customPinView.animatesDrop = true
				customPinView.canShowCallout = true

				let button = UIButton(type: .ContactAdd)
				customPinView.rightCalloutAccessoryView = button
				return customPinView
			} else {
				let annotationView = TFAnnotationView(annotation: tfAnnotation, reuseIdentifier: "ShowPhotoPin")
				annotationView.translatesAutoresizingMaskIntoConstraints = false
				annotationView.imageView.sd_setImageWithURL(tfAnnotation.node!.image!)
				return annotationView
			}
		}
		return MKAnnotationView()
	}


	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		let loc = view.annotation!.coordinate
		self.mapAddPhoto(CLLocation(latitude: loc.latitude, longitude: loc.longitude))
	}

	func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.7)
		renderer.lineWidth = 4
		renderer.lineDashPattern = [2, 7]
		return renderer
	}

	// MARK: GestureRecognizer

	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
		if let view = touch.view {
			if view.isKindOfClass(MKPinAnnotationView.self) {
				return false
			}
			return true
		}
		return false
	}

	@objc private func didLongPressed(recognizer: UILongPressGestureRecognizer) {
		switch recognizer.state {
		case .Ended:
			if let lastAnnotation = self.currentCreateAnnotation {
				self.mapView.removeAnnotation(lastAnnotation)
			}
			let point = recognizer.locationInView(self.mapView)
			let tapPoint = self.mapView.convertPoint(point, toCoordinateFromView: self.mapView)
			let annotation = TFPointAnnotation(type: .Create)
			annotation.coordinate = tapPoint
			annotation.title = "Add a photo"
			self.mapView.addAnnotation(annotation)
			self.mapView.selectAnnotation(annotation, animated: true)
			self.currentCreateAnnotation = annotation
		default:
			()
		}
	}

	// MARK: LocationManager Delegate
	private let RegionRadius: CLLocationDistance = 1000

	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let loc = locations.first!
		self.centerMapOnLocation(loc, animated: false)
	}

	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		NSLog("LocationService error: \(error)")
	}

	private func centerMapOnLocation(location: CLLocation, animated: Bool) {
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, RegionRadius * 2.0, RegionRadius * 2.0)
		self.mapView.setRegion(coordinateRegion, animated: animated)
	}

	// MARK: Add photos
	private func mapAddPhoto(location: CLLocation) {
		let imagePicker = BSImagePickerViewController()
		imagePicker.maxNumberOfSelections = 1
		bs_presentImagePickerController(imagePicker, animated: true, select: nil, deselect: nil, cancel: nil, finish: { (assets) -> Void in
			let asset = assets.first!
			self.bufferAsset = asset
			self.bufferLocation = location
			self.performSegueWithIdentifier("EditPhoto", sender: self)
			}) { () -> Void in
				NSLog("Photo pick completed")
		}
	}

	@IBAction func batchAddPhotos(sender: UIButton) {
		let imagePicker = BSImagePickerViewController()
		imagePicker.maxNumberOfSelections = 20
		bs_presentImagePickerController(imagePicker, animated: true, select: nil, deselect: nil, cancel: nil, finish: { (assets) -> Void in
			self.bufferAssets = assets
			self.performSegueWithIdentifier("BatchPhotos", sender: self)
			}) { () -> Void in
				NSLog("Photo pick completed")
		}
	}

	// MARK: Segue

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let identifier = segue.identifier {
			switch identifier {
			case "EditPhoto":
				if let photoVC = segue.destinationViewController as? UploadPhotoController {
					photoVC.asset = self.bufferAsset
					photoVC.protfolioname = self.editingPortfolioName
					photoVC.location = self.bufferLocation
				}
			case "BatchPhotos":
				if let photoVC = segue.destinationViewController as? BatchUploadController {
					photoVC.assets = self.bufferAssets
					photoVC.portfolioName = self.editingPortfolioName
				}
			default:
				()
			}
		}
	}

	// MARK: Uploads finished

	@objc private func uploadsFinished() {
		let params = ["username": ConnectedUser.sharedInstance().username!,
					  "portfolio": self.editingPortfolioName!]
		self.manager.GET(SERVER_URL + PORTFOLIO_GET_PATH, parameters: params, success: { (dataTask, response) -> Void in
			if let data = response {
				let result = PortfolioMapManager.getNodesFromJSON(data)
				self.constructMapAnnotations(result)
			}
			}) { (dataTask, error) -> Void in
				NSLog("Get Portfolio failed, error \(error.localizedDescription)")
		}
		NSLog("Update Portfolio")
	}

	// MARK: Update Maps

	private func constructMapAnnotations(nodes: [PortfolioNode]) {
		self.mapView.removeAnnotations(self.mapView.annotations)
		self.mapView.removeOverlays(self.mapView.overlays)
		self.currentCreateAnnotation = nil
		for node in nodes {
			let annotation = TFPointAnnotation(type: .Show)
			annotation.coordinate = node.location.coordinate
			annotation.node = node
			self.mapView.addAnnotation(annotation)
		}
		let sortedNode = nodes.sort { $0 < $1 }
		var sortedCoords = sortedNode.map{ $0.location.coordinate }
		if sortedCoords.count > 1 {
			let line = MKGeodesicPolyline(coordinates: &sortedCoords, count: sortedCoords.count)
			self.mapView.addOverlay(line)
		}
	}
}