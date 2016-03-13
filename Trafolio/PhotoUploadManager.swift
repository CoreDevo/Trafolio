import Foundation
import AFNetworking
import SwiftyJSON
import CoreLocation

class PhotoUploadManager: NSObject {
	static var instance: PhotoUploadManager!
	static func sharedInstance()->PhotoUploadManager {
		if self.instance == nil {
			self.instance = PhotoUploadManager()
		}
		return self.instance
	}

	private var manager: AFHTTPSessionManager {
		let manager = (UIApplication.sharedApplication().delegate as! AppDelegate).httpManager
		manager.requestSerializer.setValue(AUTH_CODE, forHTTPHeaderField: "auth_code")
		return manager
	}

	let IMAGE_PATH = "/images.php"

	func sendPhoto(imageData: NSData, filename: String, portfolioName: String, description: String, location: CLLocation) {
		let urlManager = AFURLSessionManager(sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
		let request = NSMutableURLRequest(URL: NSURL(string: SERVER_URL + IMAGE_PATH)!)
		request.HTTPMethod = "POST"
		let params = ["username": ConnectedUser.sharedInstance().username!,
			"portfolioname": portfolioName,
			"description": description,
			"latitude": location.coordinate.latitude.description,
			"longitude": location.coordinate.longitude.description]
		let boundary = self.generateBoundaryString()
		request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
		request.HTTPBody = self.createBodyWithParameters(params, filename: filename, filePathKey: "file", imageDataKey: imageData, boundary: boundary)
		let task = urlManager.dataTaskWithRequest(request) { (data, response, error) -> Void in
			if error != nil {
				print("error=\(error)")
				return
			}

			// You can print out response object
			print("******* response = \(response)")

		}
		task.resume()

	}

	func generateBoundaryString() -> String {
		return "Boundary-\(NSUUID().UUIDString)"
	}

	func createBodyWithParameters(parameters: [String: String]?, filename: String, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
		var body = NSMutableData();

		if parameters != nil {
			for (key, value) in parameters! {
				body.appendString("--\(boundary)\r\n")
				body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
				body.appendString("\(value)\r\n")
			}
		}

		let mimetype = "image/jpg"

		body.appendString("--\(boundary)\r\n")
		body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
		body.appendString("Content-Type: \(mimetype)\r\n\r\n")
		body.appendData(imageDataKey)
		body.appendString("\r\n")



		body.appendString("--\(boundary)--\r\n")
		
		return body
	}


	
}