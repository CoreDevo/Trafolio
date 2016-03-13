import CoreLocation
import Foundation

struct PortfolioNode {
	var image: NSURL?
	var location: CLLocation
	var description: String?
	var date: NSDate
}

func < (lhs: PortfolioNode, rhs: PortfolioNode) -> Bool {
	return lhs.date.timeIntervalSinceDate(rhs.date) < 0
}