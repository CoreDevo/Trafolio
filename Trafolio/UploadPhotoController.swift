import UIKit
import AFNetworking
import PhotosUI


class UploadPhotoController: UIViewController {
	@IBOutlet weak var thumbnail: UIImageView!
	@IBOutlet weak var filenameTF: UITextField!
	@IBOutlet weak var locationInfo: UILabel!
	@IBOutlet weak var descriptionView: UITextView!

	var asset: PHAsset!
	var protfolioname: String!
	var photo: UIImage?

	var locationManager: CLLocationManager {
		return (UIApplication.sharedApplication().delegate as! AppDelegate).locationManager
	}
	var geocodeManager: CLGeocoder {
		return (UIApplication.sharedApplication().delegate as! AppDelegate).geocodeManager
	}

	var location: CLLocation!

	override func viewWillAppear(animated: Bool) {
		let manager = PHImageManager()
		let options = PHImageRequestOptions()
		options.synchronous = true
		options.deliveryMode = .Opportunistic
		manager.requestImageForAsset(self.asset, targetSize: CGSizeMake(CGFloat(self.asset.pixelWidth) / 2, CGFloat(self.asset.pixelHeight) / 2), contentMode: .AspectFit, options: options) { (image, info) -> Void in
			var filename: String?
			if info!.keys.contains(NSString(string: "PHImageFileURLKey"))
			{
				if let image = image {
					let path = info![NSString(string: "PHImageFileURLKey")] as! NSURL
					filename = path.lastPathComponent
					self.filenameTF.text = filename
					self.photo = image
					self.thumbnail.image = image
				}
			}
		}
		self.geocodeManager.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
			if error == nil {
				self.locationInfo.text = placemarks?.first?.name
			}
		})
	}
	
	@IBAction func upload(sender: UIBarButtonItem) {
		let filename = self.filenameTF.text ?? "0.jpg"
		let portfolioname = self.protfolioname
		let	description = self.descriptionView.text
		guard let data = UIImageJPEGRepresentation(self.photo!, 0.8) else { return }
		let date = self.asset.creationDate ?? NSDate()
		PhotoUploadManager.sharedInstance().sendPhoto(data, filename: filename, portfolioName: portfolioname, description: description, location:self.location, date: date) {(succeed) -> () in
			NSLog("Result: \(succeed)")
			NSNotificationCenter.defaultCenter().postNotificationName(TrafolioUploadCompletedNotification, object: self)
		}
		self.navigationController?.popViewControllerAnimated(true)
	}
	
}