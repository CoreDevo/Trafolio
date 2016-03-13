import CoreLocation
import Foundation

struct PortfolioNode {
	var image: NSURL?
	var location: CLLocation
	var description: String?
	var date: NSDate
}


struct Portfolio {
	var username: String
	var name: String
	var num_pic: Int
	var description: String?
	var isPublic: Bool
	var finished: Bool
	var date: NSDate
}


func < (lhs: PortfolioNode, rhs: PortfolioNode) -> Bool {
	return lhs.date.timeIntervalSinceDate(rhs.date) < 0
}

func < (lhs: Portfolio, rhs: Portfolio) -> Bool {
	return lhs.date.timeIntervalSinceDate(rhs.date) < 0
}