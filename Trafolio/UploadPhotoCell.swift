import UIKit
import PhotosUI

class UploadPhotoCell: UITableViewCell {
	@IBOutlet weak var thumbnail: UIImageView!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var descriptionView: UITextField!

	private var filename: String!
	private var photo: UIImage!
	private var location: CLLocation!

	var locationManager: CLLocationManager {
		return (UIApplication.sharedApplication().delegate as! AppDelegate).locationManager
	}
	var geocodeManager: CLGeocoder {
		return (UIApplication.sharedApplication().delegate as! AppDelegate).geocodeManager
	}

	func populate(asset: PHAsset) {
		let manager = PHImageManager()
		let options = PHImageRequestOptions()
		options.synchronous = true
		manager.requestImageForAsset(asset, targetSize: CGSizeMake(CGFloat(asset.pixelWidth) / 3, CGFloat(asset.pixelHeight) / 3), contentMode: .AspectFit, options: options) { (image, info) -> Void in
			var filename: String?
			if info!.keys.contains(NSString(string: "PHImageFileURLKey"))
			{
				if let image = image {
					let path = info![NSString(string: "PHImageFileURLKey")] as! NSURL
					filename = path.lastPathComponent
					self.filename = filename
					self.photo = image
					self.thumbnail.image = image
				}
			}
		}
		if let location = asset.location {
			self.location = location
			self.geocodeManager.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
				if error == nil {
					self.locationLabel.text = placemarks?.first?.name
				}
			})
		} else {
			self.location = self.locationManager.location
			self.geocodeManager.reverseGeocodeLocation(self.location, completionHandler: { (placemarks, error) -> Void in
				if error == nil {
					self.locationLabel.text = placemarks?.first?.name
				}
			})
		}
	}
}