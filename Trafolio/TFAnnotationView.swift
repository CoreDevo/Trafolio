import MapKit

class TFAnnotationView: MKAnnotationView {
	@IBOutlet var nibView: UIView!
	@IBOutlet weak var imageView: UIImageView!


	override init(frame: CGRect) {
		super.init(frame: frame)
		self.initFromNib()
	}

	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		self.initFromNib()
	}


	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initFromNib()
	}

	func initFromNib() {
		let bundle = NSBundle(forClass: self.dynamicType)
		bundle.loadNibNamed(self.className, owner: self, options: nil)
		nibView.frame = self.bounds
		self.addSubview(nibView)
	}
}