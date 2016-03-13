import UIKit


class MeViewController: UIViewController {
	@IBOutlet weak var createButton: UIBarButtonItem!

	private var enteringPortfolio: String?


	@IBAction func createNewProfolio(sender: UIBarButtonItem) {
		self.performSegueWithIdentifier("MeCreate", sender: self)
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if let portfolio = ConnectedUser.sharedInstance().shouldEnterPortfolio {
			ConnectedUser.sharedInstance().shouldEnterPortfolio = nil
			self.enteringPortfolio = portfolio
			self.performSegueWithIdentifier("EditPortfolio", sender: self)
		}
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let identifier = segue.identifier {
			switch identifier {
			case "EditPortfolio":
				if let editVC = segue.destinationViewController as? EditPortfolioController {
					editVC.title = self.enteringPortfolio
					editVC.editingPortfolioName = self.enteringPortfolio
				}
			default:
				()
			}
		}
	}
}