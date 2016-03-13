import Foundation

class ConnectedUser: NSObject {
	static var instance: ConnectedUser!
	static func sharedInstance () -> ConnectedUser {
		if self.instance == nil {
			self.instance = ConnectedUser()
		}
		return self.instance
	}

	var connected: Bool = false
	var username: String?
	var shouldEnterPortfolio: String?
}