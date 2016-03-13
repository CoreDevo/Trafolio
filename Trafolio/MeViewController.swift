import UIKit
import AFNetworking


class MeViewController: UIViewController {
	@IBOutlet weak var createButton: UIBarButtonItem!
	@IBOutlet weak var portfolioTableView: UITableView!

	private var enteringPortfolio: String?
	private var portfolioDelegate: PortfolioTableViewDelegate!


	let PORTFOLIO_LIST_PATH = "/getportfolio.php"

	private var manager: AFHTTPSessionManager {
		let manager = (UIApplication.sharedApplication().delegate as! AppDelegate).httpManager
		manager.requestSerializer.setValue(AUTH_CODE, forHTTPHeaderField: "auth_code")
		return manager
	}

	@IBAction func createNewProfolio(sender: UIBarButtonItem) {
		self.performSegueWithIdentifier("MeCreate", sender: self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.portfolioDelegate = PortfolioTableViewDelegate(tableView: self.portfolioTableView)
		self.portfolioTableView.delegate = self.portfolioDelegate
		self.portfolioTableView.dataSource = self.portfolioDelegate
		self.portfolioDelegate.parentVC = self
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if let portfolio = ConnectedUser.sharedInstance().shouldEnterPortfolio {
			ConnectedUser.sharedInstance().shouldEnterPortfolio = nil
			self.enteringPortfolio = portfolio
			self.performSegueWithIdentifier("EditPortfolio", sender: self)
		} else {
			let params = ["username": ConnectedUser.sharedInstance().username!]
			self.manager.GET(SERVER_URL + PORTFOLIO_LIST_PATH, parameters: params, progress: nil, success: { (dataTask, response) -> Void in
				if let data = response {
					let result = PortfolioMapManager.getPortfolioFromJSON(data)
					self.portfolioDelegate.portfolios = result
					self.portfolioTableView.reloadData()
				}
				}, failure: { (dataTask, error) -> Void in
					NSLog("Get portfolio list failed, error: \(error.localizedDescription)")
			})
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
			case "MeOpenView":
				if let viewVC = segue.destinationViewController as? ViewPortfolioController {
					viewVC.portfolio = self.portfolioDelegate.selectedPortfolio
					viewVC.title = self.portfolioDelegate.selectedPortfolio?.name
				}
			default:
				()
			}
		}
	}
}