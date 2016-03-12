import UIKit

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

	private var validUsername = false
	private var validPassword = false
	private var validConfirmation = false

	struct LabelContents {
		static let UsernameTooShort = "Username should be longer than 4 characters"
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