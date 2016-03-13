import Foundation
import MapKit
import SwiftyJSON

class PortfolioMapManager: NSObject {
	static func getNodesFromJSON(jsonData: AnyObject) -> [PortfolioNode] {
		let json = JSON(jsonData)
		var result:[PortfolioNode] = []
		for node in json.arrayValue {
			let imageURL = node["url"].URL
			let description = node["description"].stringValue
			let date = NSDate(timeIntervalSince1970: node["date"].doubleValue)
			let latitude = node["latitude"].doubleValue
			let longitude = node["longitude"].doubleValue
			let location = CLLocation(latitude: latitude, longitude: longitude)
			let newNode = PortfolioNode(image: imageURL, location: location, description: description, date: date)
			result.append(newNode)
		}
		result.sortInPlace { $0 < $1 }
		return result
	}

	static func getPortfolioFromJSON(jsonData: AnyObject) -> [Portfolio] {
		let json = JSON(jsonData)
		var result:[Portfolio] = []
		for portfolio in json.arrayValue {
			let username = portfolio["username"].stringValue
			let name = portfolio["name"].stringValue
			let num_pic = portfolio["num_pic"].intValue
			let description = portfolio["description"].stringValue
			let isPublic = portfolio["public"].stringValue == "true"
			let finished = portfolio["finished"].intValue == 1
			let date = NSDate(timeIntervalSince1970:  portfolio["date"].doubleValue)

			let newPortfolio = Portfolio(username: username, name: name, num_pic:  num_pic, description: description, isPublic: isPublic, finished: finished, date: date)
			result.append(newPortfolio)
		}
		result.sortInPlace { $0 < $1 }
		return result
	}
}