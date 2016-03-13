import UIKit


class DashboardController: UIViewController {
	@IBOutlet weak var createButton: UIBarButtonItem!

	// MARK: Button Events

	@IBAction func createNewProfolio(sender: UIBarButtonItem) {
		self.performSegueWithIdentifier("DashboardCreate", sender: self)
	}

}