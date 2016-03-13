import UIKit
import AFNetworking
import MapKit
import BSImagePicker
import PhotosUI

class EditPortfolioController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	var editingPortfolioName: String?

	@IBOutlet weak var mapView: MKMapView!

	let IMAGE_PATH = "/images.php"

	private var mapTapRecognizer: UIGestureRecognizer!
	private var locationManager = CLLocationManager()

	private var manager: AFHTTPSessionManager {
		let manager = (UIApplication.sharedApplication().delegate as! AppDelegate).httpManager
		manager.requestSerializer.setValue(AUTH_CODE, forHTTPHeaderField: "auth_code")
		return manager
	}

	private var bufferAsset: PHAsset!
	private var bufferLocation: CLLocation!


	override func viewDidLoad() {
		super.viewDidLoad()
		self.mapView.delegate = self
		self.mapTapRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("didLongPressed:"))
		self.mapTapRecognizer.delegate = self
		self.locationManager.delegate = self
		self.mapView.addGestureRecognizer(self.mapTapRecognizer)

		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.requestLocation()
	}

	// MARK: MapView Delegate

	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		let customPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "AddPhotoCallout")
		customPinView.pinTintColor = UIColor.redColor()
		customPinView.animatesDrop = true
		customPinView.canShowCallout = true

		let button = UIButton(type: .ContactAdd)
		customPinView.rightCalloutAccessoryView = button
		return customPinView
	}

	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		let loc = view.annotation!.coordinate
		self.mapAddPhoto(CLLocation(latitude: loc.latitude, longitude: loc.longitude))
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
			self.mapView.removeAnnotations(self.mapView.annotations)
			let point = recognizer.locationInView(self.mapView)
			let tapPoint = self.mapView.convertPoint(point, toCoordinateFromView: self.mapView)
			let annotation = MKPointAnnotation()
			annotation.coordinate = tapPoint
			annotation.title = "Add a photo"
			self.mapView.addAnnotation(annotation)
			self.mapView.selectAnnotation(annotation, animated: true)
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
			default:
				()
			}
		}
	}
}