import UIKit
import AFNetworking


class DashboardController: UIViewController {
	@IBOutlet weak var createButton: UIBarButtonItem!
	@IBOutlet var tableView: UITableView!

	private var portfolioDelegate: PortfolioTableViewDelegate!

	let PUBLIC_LIST_PATH = "/randompublic.php"

	private var manager: AFHTTPSessionManager {
		let manager = (UIApplication.sharedApplication().delegate as! AppDelegate).httpManager
		manager.requestSerializer.setValue(AUTH_CODE, forHTTPHeaderField: "auth_code")
		return manager
	}

	// MARK: Button Events

	@IBAction func createNewProfolio(sender: UIBarButtonItem) {
		self.performSegueWithIdentifier("DashboardCreate", sender: self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.portfolioDelegate = PortfolioTableViewDelegate(tableView: self.tableView)
		self.tableView.delegate = self.portfolioDelegate
		self.tableView.dataSource = self.portfolioDelegate
		self.portfolioDelegate.parentVC = self
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		let params = ["username": ConnectedUser.sharedInstance().username!]
		self.manager.GET(SERVER_URL + PUBLIC_LIST_PATH, parameters: params, progress: nil, success: { (dataTask, response) -> Void in
			print(response)
			if let data = response {
				let result = PortfolioMapManager.getPortfolioFromJSON(data)
				self.portfolioDelegate.portfolios = result
				self.tableView.reloadData()
			}
			}, failure: { (dataTask, error) -> Void in
				NSLog("Get portfolio list failed, error: \(error.localizedDescription)")
		})
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let identifier = segue.identifier {
			switch identifier {
			case "DashboardOpenView":
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