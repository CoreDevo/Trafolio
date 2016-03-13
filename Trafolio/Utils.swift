import Foundation

extension NSMutableData {

	func appendString(string: String) {
		let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
		appendData(data!)
	}
}

extension UIImage {
	func scaleImage(toSize newSize: CGSize) -> (UIImage) {
		let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
		let context = UIGraphicsGetCurrentContext()
		CGContextSetInterpolationQuality(context, .High)
		let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
		CGContextConcatCTM(context, flipVertical)
		CGContextDrawImage(context, newRect, self.CGImage)
		let newImage = UIImage(CGImage: CGBitmapContextCreateImage(context)!)
		UIGraphicsEndImageContext()
		return newImage
	}
}

extension NSObject {
	var className: String {
		return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last ?? ""
	}
}