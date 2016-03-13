import Foundation
import MapKit

enum TFPointAnnotationType {
	case Create
	case Show
}

class TFPointAnnotation: MKPointAnnotation {
	var type: TFPointAnnotationType
	var node: PortfolioNode?

	init(type: TFPointAnnotationType) {
		self.type = type
		super.init()
	}
}