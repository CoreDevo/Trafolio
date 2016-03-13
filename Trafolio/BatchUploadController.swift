import UIKit
import PhotosUI
import CoreLocation

class BatchUploadController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

	@IBOutlet weak var tableView: UITableView!

	var assets: [PHAsset]!
	var portfolioName: String!
	private var images: [UIImage]!
	private var locations: [CLLocation]!
	private var locationNames: [String?]!
	private var	filenames: [String]!
	private var processed: [Bool]!
	private var descriptions: [String?]!
	private var inited = false

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
		self.filenames = Array<String>(count: self.assets.count, repeatedValue: "")
		self.processed = Array<Bool>(count: self.assets.count, repeatedValue: false)
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

	private func startLoadData() {
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

					if let location = self.assets[index].location {
						self.locations[index] = location
						self.geocodeManager.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
							if error == nil {
								let place = placemarks?.first?.name
								self.locationNames[index] = place
							}
						})
					} else {
						self.locations[index] = self.locationManager.location!
						self.geocodeManager.reverseGeocodeLocation(self.locationManager.location!, completionHandler: { (placemarks, error) -> Void in
							if error == nil {
								let place = placemarks?.first?.name
								self.locationNames[index] = place
							}
						})
					}
					self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
				}
			}
		}
		print(self.filenames)
	}


	@IBAction func uploadPhotos(sender: UIBarButtonItem) {
		for index in 0..<self.assets.count {
			if let data = UIImageJPEGRepresentation(self.images[index], 1) {
				PhotoUploadManager.sharedInstance().sendPhoto(data, filename: self.filenames[index], portfolioName: self.portfolioName, description: self.descriptions[index] ?? "", location: self.locations[index])
			} else {
				NSLog("Photo at index \(index) failed upload")
			}
		}
		self.navigationController?.popViewControllerAnimated(true)
	}
}