import UIKit

class SettingsViewController: UIViewController {

	@IBAction func signout(sender: AnyObject) {
		ConnectedUser.sharedInstance().connected = false
		ConnectedUser.sharedInstance().username = nil
		self.dismissViewControllerAnimated(true, completion: nil)
	}
}