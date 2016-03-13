import UIKit
import AFNetworking

class CreatePortfolioViewController: UIViewController {
	@IBOutlet weak var titleTF: UITextField!
	@IBOutlet weak var accessSwitch: UISwitch!
	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var createButton: UIBarButtonItem!

	let PROFOLIO_PATH = "/newportfolio.php"

	private var manager: AFHTTPSessionManager {
		let manager = (UIApplication.sharedApplication().delegate as! AppDelegate).httpManager
		manager.requestSerializer.setValue(AUTH_CODE, forHTTPHeaderField: "auth_code")
		return manager
	}

	@IBAction func createNewProfolio(sender: AnyObject) {
		if self.titleTF.text == nil || self.titleTF.text == "" {
			let alert = UIAlertController(title: "Cannot create Portfolio", message: "Please give a title for your Portfolio", preferredStyle: .Alert)
			let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
			alert.addAction(ok)
			self.presentViewController(alert, animated: true, completion: nil)
		} else {
			let params = [
				"username": ConnectedUser.sharedInstance().username!,
				"title": self.titleTF.text!,
				"public": self.accessSwitch.on ? "true" : "false",
				"description": self.descriptionTextView.text
			]
			self.manager.POST(SERVER_URL + PROFOLIO_PATH, parameters: params, success: { (dataTask, response) -> Void in
					NSLog("Create portfolio succeed")
				if let tabVC = self.navigationController?.parentViewController as? UITabBarController {
					tabVC.selectedIndex = 1
					ConnectedUser.sharedInstance().shouldEnterPortfolio = self.titleTF.text!
				}
				self.navigationController?.popToRootViewControllerAnimated(false)
				}, failure: { (dataTask, error) -> Void in
					NSLog("Create portfolio failed, error: \(error.localizedDescription)")
			})
		}
	}
}