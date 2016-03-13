import UIKit
import AFNetworking
import SwiftyJSON

class LoginViewController: UIViewController {

	@IBOutlet weak var loginBox: UIView!
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var signupButton: UIButton!
	@IBOutlet weak var logoImage: UIImageView!

	let LOGIN_PATH = "/login.php"

	private var manager: AFHTTPSessionManager {
		let manager = (UIApplication.sharedApplication().delegate as! AppDelegate).httpManager
		manager.requestSerializer.setValue(AUTH_CODE, forHTTPHeaderField: "auth_code")
		return manager
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


	// MARK: Appears Events

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		UIView.animateWithDuration(0.5) { () -> Void in
			self.loginBox.alpha = 1
			self.logoImage.alpha = 1
		}
		self.usernameTextField.text = nil
		self.passwordTextField.text = nil
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillAppear(animated)
		UIView.animateWithDuration(0.5) { () -> Void in
			self.loginBox.alpha = 0
			self.logoImage.alpha = 0
		}
	}

	// MARK: Button Events

	@IBAction func loginAction(sender: AnyObject) {
		let username = self.usernameTextField.text!
		let password = self.passwordTextField.text!
		let encrptyedPW = password.md5()
		let params = [
			"username": username,
			"password": encrptyedPW
		]

		self.manager.POST(SERVER_URL + LOGIN_PATH, parameters: params, success: { (dataTask, response) -> Void in
				NSLog("POST request succeed")
				if let data = response {
					let json = JSON(data)
					let result = json["result"].stringValue
					if result == "fail" {
						let alert = UIAlertController(title: "Login Failed", message: "Invalid password", preferredStyle: .Alert)
						let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
						alert.addAction(ok)
						self.presentViewController(alert, animated: true, completion: { () -> Void in
							self.passwordTextField.text = nil
						})
					} else if result == "nouser" {
						let alert = UIAlertController(title: "Login Failed", message: "No such user", preferredStyle: .Alert)
						let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
						alert.addAction(ok)
						self.presentViewController(alert, animated: true, completion: { () -> Void in
							self.passwordTextField.text = nil
						})
					} else if result == "succeed" {
						ConnectedUser.sharedInstance().username = username
						ConnectedUser.sharedInstance().connected = true
						self.performSegueWithIdentifier("Login", sender: self)
					}
				} else {
					NSLog("No response")
				}
			}, failure: { (dataTask, error) -> Void in
				NSLog("POST request failed, error: \(error.localizedDescription)")
		})
	}

	@IBAction func signupAction(sender: AnyObject) {
		let signupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SignUp") as! SignupViewController;
		signupVC.loginVC = self
		self.presentViewController(signupVC, animated: true, completion: nil)
	}

	// MARK: Segue

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		super.prepareForSegue(segue, sender: sender)
	}

	// MARK: Keyboard Events

	@objc private func keyboardWillShow(notification: NSNotification) {
		if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
			let keyboardHeight = keyboardFrame.size.height - 60
			let transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -keyboardHeight)
			UIView.animateWithDuration(0.5, animations: { () -> Void in
				self.loginBox.transform = transform
				self.logoImage.alpha = 0
			})
		}
	}

	@objc private func keyboardWillHide(notification: NSNotification) {
		UIView.animateWithDuration(0.5) { () -> Void in
			self.loginBox.transform = CGAffineTransformIdentity
			self.logoImage.alpha = 1
		}
	}
}

