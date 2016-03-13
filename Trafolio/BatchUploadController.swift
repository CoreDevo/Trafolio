import UIKit
import PhotosUI
import CoreLocation

let TrafolioUploadCompletedNotification = "TrafolioUploadCompletedNotification"

enum UploadState {
	case Success
	case Failed
	case Waiting
}

class BatchUploadController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

	@IBOutlet weak var tableView: UITableView!

	var assets: [PHAsset]!
	var portfolioName: String!
	private var images: [UIImage]!
	private var locations: [CLLocation]!
	private var locationNames: [String?]!
	private var dates: [NSDate]!
	private var	filenames: [String]!
	private var processed: [UploadState]!
	private var descriptions: [String?]!
	private var inited = false

	private let geocoderQuene = dispatch_queue_create("game_manager_queue", DISPATCH_QUEUE_SERIAL)

	var locationManager: CLLocationManager {
		return (UIApplication.sharedApplication().delegate as! AppDelegate).locationManager
	}
	var geocodeManager: CLGeocoder {
		return (UIApplication.sharedApplication().delegate as! AppDelegate).geocodeManager
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.registerNib(UINib(nibName: "UploadPhotoCell", bundle: nil), forCellReuseIdentifier: "UploadPhotoCell")
	}


	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.setupContainers()
		self.startLoadData()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.tableView.reloadData()
	}

	func setupContainers() {
		self.inited = true
		self.images = Array<UIImage>(count: self.assets.count, repeatedValue: UIImage(named: "placeholder")!)
		self.locations = Array<CLLocation>(count: self.assets.count, repeatedValue: CLLocation())
		self.locationNames = Array<String?>(count: self.assets.count, repeatedValue: nil)
		self.dates = Array<NSDate>(count: self.assets.count, repeatedValue: NSDate())
		self.filenames = Array<String>(count: self.assets.count, repeatedValue: "")
		self.processed = Array<UploadState>(count: self.assets.count, repeatedValue: .Waiting)
		self.descriptions = Array<String?>(count: self.assets.count, repeatedValue: nil)
		self.tableView.delegate = self
		self.tableView.dataSource = self
	}

	// MARK: TableView Delegate

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.assets == nil {
			return 0
		}
		return self.assets.count
	}

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 100
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if !self.inited {
			return UploadPhotoCell()
		}
		let cell = tableView.dequeueReusableCellWithIdentifier("UploadPhotoCell") as! UploadPhotoCell
		let index = indexPath.row
		cell.thumbnail.image = self.images[index]
		cell.locationLabel.text = self.locationNames[index]
		cell.selectionStyle = .None
		cell.descriptionView.tag = index
		cell.descriptionView.delegate = self
		cell.descriptionView.text = self.descriptions[index]
		switch self.processed[index] {
		case .Waiting:
			cell.descriptionView.backgroundColor = UIColor.whiteColor()
		case .Success:
			cell.descriptionView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.7)
		case .Failed:
			cell.descriptionView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.7)
		}
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! UploadPhotoCell
		cell.descriptionView.becomeFirstResponder()
	}


	func textFieldDidEndEditing(textField: UITextField) {
		let index = textField.tag
		self.descriptions[index] = textField.text
	}

	private func loadNextGeocode(index: Int) -> () {
		if index == self.assets.count {return}
		if let location = self.assets[index].location {
			self.locations[index] = location
			self.geocodeManager.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
				if error == nil {
					let place = placemarks?.first?.name
					self.locationNames[index] = place
					self.loadNextGeocode(index+1)
					self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
				}
			})
		} else {
			self.locations[index] = self.locationManager.location!
			self.geocodeManager.reverseGeocodeLocation(self.locationManager.location!, completionHandler: { (placemarks, error) -> Void in
				if error == nil {
					let place = placemarks?.first?.name
					self.locationNames[index] = place
					self.loadNextGeocode(index+1)
					self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
				}
			})
		}
	}

	private func startLoadData() {
		self.loadNextGeocode(0)
		for index in 0..<self.assets.count {
			let manager = PHImageManager()
			let options = PHImageRequestOptions()
			options.synchronous = true
			options.deliveryMode = .Opportunistic
			manager.requestImageForAsset(self.assets[index], targetSize: CGSizeMake(CGFloat(self.assets[index].pixelWidth) / 2, CGFloat(self.assets[index].pixelHeight) / 2), contentMode: .AspectFit, options: options) { (image, info) -> Void in
				print(info)
				if info!.keys.contains(NSString(string: "PHImageFileURLKey")) {
					let path = info![NSString(string: "PHImageFileURLKey")] as! NSURL
					let filename = path.lastPathComponent
					print("\(filename) -> \(index)")
					self.filenames[index] = filename!
				} else {
					if let data = UIImageJPEGRepresentation(image!, 0.01), let dataString = String(data: data, encoding: NSASCIIStringEncoding) {
						let filename = dataString.md5() + ".jpg"
						self.filenames[index] = filename
					} else {
						let filename = "non_name.jpg"
						self.filenames[index] = filename
					}
				}
				if let image = image {

					self.images[index] = image

					if let date = self.assets[index].creationDate {
						self.dates[index] = date
					}

					self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
				}
			}
		}
		print(self.filenames)
	}


	@IBAction func uploadPhotos(sender: UIBarButtonItem) {
		let checkDone = {
			var done = true
			for state in self.processed {
				done = done && state != .Waiting
			}
			if done {
				NSNotificationCenter.defaultCenter().postNotificationName(TrafolioUploadCompletedNotification, object: self)
			}
		}
		sender.enabled = false
		for index in 0..<self.assets.count {
			if let data = UIImageJPEGRepresentation(self.images[index], 0.8) {
				PhotoUploadManager.sharedInstance().sendPhoto(data, filename: self.filenames[index], portfolioName: self.portfolioName, description: self.descriptions[index] ?? "", location: self.locations[index], date: self.dates[index]) { (succeed) -> () in
					self.processed[index] = succeed ? .Success : .Failed
					self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
					checkDone()
				}
			} else {
				NSLog("Photo at index \(index) failed upload")
				self.processed[index] = .Failed
				checkDone()
			}
		}
	}
}