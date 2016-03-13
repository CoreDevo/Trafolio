import Foundation

extension NSMutableData {

	func appendString(string: String) {
		let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
		appendData(data!)
	}
}