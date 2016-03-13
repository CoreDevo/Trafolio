import UIKit
import AFNetworking
import CryptoSwift
import SwiftyJSON

class SignupViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var signupBox: UIView!
	@IBOutlet weak var usernameTF: UITextField!
	@IBOutlet weak var passwordTF: UITextField!
	@IBOutlet weak var confirmPasswordTF: UITextField!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var passwordLabel: UILabel!
	@IBOutlet weak var confirmPasswordLabel: UILabel!
	@IBOutlet weak var signupButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var spinnerView: UIView!

	weak var loginVC: LoginViewController?

	private var spinner: UIActivityIndicatorView!

	private var validUsername = false
	private var validPassword = false
	private var validConfirmation = false

	let SIGNUP_PATH = "/register.php"

	private var manager: AFHTTPSessionManager {
		let manager = (UIApplication.sharedApplication().delegate as! AppDelegate).httpManager
		manager.requestSerializer.setValue(AUTH_CODE, forHTTPHeaderField: "auth_code")
		return manager
	}

	struct LabelContents {
		static let UsernameTooShort = "Username should be longer than 4 characters"
		static let UsernameExist = "Username already exist"
		static let PasswordTooShort = "Password should be at least 6 characters long"
		static let ConfirmNotMatch = "Passwords do not match"
		static let EnterPassword = "Please enter a password"
		static let Valid = "Valid"
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.alpha = 0
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)

		self.signupButton.enabled = false
		self.signupButton.setTitleColor(UIColor.grayColor(), forState: .Normal)

		self.usernameTF.delegate = self
		self.usernameTF.tag = 0
		self.passwordTF.delegate = self
		self.passwordTF.tag = 1
		self.confirmPasswordTF.delegate = self
		self.confirmPasswordTF.tag = 2

		self.usernameTF.addTarget(self, action: Selector("textFieldEdited:"), forControlEvents: .EditingChanged)
		self.passwordTF.addTarget(self, action: Selector("textFieldEdited:"), forControlEvents: .EditingChanged)
		self.confirmPasswordTF.addTarget(self, action: Selector("textFieldEdited:"), forControlEvents: .EditingChanged)

		self.spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
		self.spinnerView.addSubview(self.spinner)
		self.spinner.translatesAutoresizingMaskIntoConstraints = false
		let attributes: [NSLayoutAttribute] = [.Top, .Bottom, .Leading, .Trailing]
		var mConstraints: [NSLayoutConstraint] = []
		for attr in attributes {
			mConstraints.append(NSLayoutConstraint(item: self.spinner, attribute: attr, relatedBy: .Equal, toItem: self.spinnerView, attribute: attr, multiplier: 1, constant: 0))
		}
		self.spinnerView.addConstraints(mConstraints)

		self.spinnerView.hidden = true
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
		NSLog("SignUpViewController Deinit")
	}

	// MARK: Appear Events

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		UIView.animateWithDuration(0.5) { () -> Void in
			self.view.alpha = 1
		}
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		UIView.animateWithDuration(0.5) { () -> Void in
			self.view.alpha = 0
		}
	}

	// MARK: Button Events

	@IBAction func signupAction(sender: UIButton) {
		self.spinnerView.hidden = false
		self.signupButton.hidden = true
		self.spinner.startAnimating()

		let encryptedPW = self.passwordTF.text!.md5()
		let params = ["username": self.usernameTF.text!, "password":encryptedPW]

		self.manager.POST(SERVER_URL + SIGNUP_PATH, parameters: params, success: { (dataTask, response) -> Void in
			NSLog("POST request succeed")
			if let data = response {
				let json = JSON(data)
				let result = json["result"].stringValue
				if result == "succeed" {
					self.loginVC?.usernameTextField.text = self.usernameTF.text
					self.dismissViewControllerAnimated(true, completion: nil)
				} else if result == "exist" {
					self.spinner.stopAnimating()
					self.spinnerView.hidden = true
					self.signupButton.hidden = false
					self.usernameLabel.text = LabelContents.UsernameExist
					self.usernameLabel.textColor = UIColor.redColor()
					self.signupButton.enabled = false
					self.signupButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
				}

			} else {
				self.spinner.stopAnimating()
				self.spinnerView.hidden = true
				self.signupButton.hidden = false
				let alert = UIAlertController(title: "Error", message: "No response from server", preferredStyle: .Alert)
				let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
				alert.addAction(ok)
				self.presentViewController(alert, animated: true, completion: nil)
			}
			}, failure: { (dataTask, error) -> Void in
				NSLog("POST request failed, error: \(error.localizedDescription)")
		})
	}

	@IBAction func cancelAction(sender: UIButton) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	// MARK: TextField Delegate

	@objc private func textFieldEdited(textField: UITextField)  {
		switch textField.tag {
		case 0:
			if let length = textField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) {
				if length < 4 {
					self.usernameLabel.text = LabelContents.UsernameTooShort
					self.usernameLabel.textColor = UIColor.redColor()
					self.validUsername = false
				} else {
					self.usernameLabel.text = LabelContents.Valid
					self.usernameLabel.textColor = UIColor.greenColor()
					self.validUsername = true
				}
			} else {
				self.usernameLabel.text = LabelContents.UsernameTooShort
				self.usernameLabel.textColor = UIColor.redColor()
				self.validUsername = false
			}
		case 1:
			if let length = textField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) {
				if length < 6 {
					self.passwordLabel.text = LabelContents.PasswordTooShort
					self.passwordLabel.textColor = UIColor.redColor()
					self.validPassword = false
				} else {
					self.passwordLabel.text = LabelContents.Valid
					self.passwordLabel.textColor = UIColor.greenColor()
					self.validPassword = true
				}
			} else {
				self.passwordLabel.text = LabelContents.PasswordTooShort
				self.passwordLabel.textColor = UIColor.redColor()
				self.validPassword = false
			}
		case 2:
			if let text = textField.text {
				if text == self.passwordTF.text {
					self.confirmPasswordLabel.text = LabelContents.Valid
					self.confirmPasswordLabel.textColor = UIColor.greenColor()
					self.validConfirmation = true
				} else if text == "" {
					self.confirmPasswordLabel.text = LabelContents.EnterPassword
					self.confirmPasswordLabel.textColor = UIColor.redColor()
					self.validConfirmation = false
				} else {
					self.confirmPasswordLabel.text = LabelContents.ConfirmNotMatch
					self.confirmPasswordLabel.textColor = UIColor.redColor()
					self.validConfirmation = false
				}
			}
		default:
			() // Do nothing
		}

		if self.validUsername && self.validPassword && self.validConfirmation {
			self.signupButton.enabled = true
			self.signupButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		} else {
			self.signupButton.enabled = false
			self.signupButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
		}
	}

	// MARK: Keyboard Events

	@objc private func keyboardWillShow(notification: NSNotification) {
		if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
			let keyboardHeight = keyboardFrame.size.height - 120
			let transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -keyboardHeight)
			UIView.animateWithDuration(0.5, animations: { () -> Void in
				self.signupBox.transform = transform
			})
		}
	}

	@objc private func keyboardWillHide(notification: NSNotification) {
		UIView.animateWithDuration(0.5) { () -> Void in
			self.signupBox.transform = CGAffineTransformIdentity
		}
	}
}