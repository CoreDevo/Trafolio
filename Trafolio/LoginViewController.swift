import UIKit

class LoginViewController: UIViewController {

	@IBOutlet weak var loginBox: UIView!
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var signupButton: UIButton!
	@IBOutlet weak var logoImage: UIImageView!



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
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillAppear(animated)
		UIView.animateWithDuration(0.5) { () -> Void in
			self.loginBox.alpha = 0
			self.logoImage.alpha = 0
		}
	}

	// MARK: Button Events

	@IBAction func signupAction(sender: AnyObject) {
		let signupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SignUp");
		self.presentViewController(signupVC, animated: true, completion: nil)
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

