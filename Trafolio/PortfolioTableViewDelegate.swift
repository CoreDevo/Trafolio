import UIKit


struct Portfolio {
	var username: String
	var name: String
	var num_pic: Int
	var description: String?
	var isPublic: Bool
	var finished: Bool
	var date: NSDate
}

class PortfolioTableViewDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
	var tableView: UITableView!
	var portfolios: [Portfolio] = []
	var selectedPortfolio: Portfolio?

	weak var parentVC: UIViewController?

	init(tableView: UITableView) {
		self.tableView = tableView
		self.tableView.registerNib(UINib(nibName: "PortfolioCell", bundle: nil) , forCellReuseIdentifier: "PortfolioCell")
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 122
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.portfolios.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let index = indexPath.row
		let cell = tableView.dequeueReusableCellWithIdentifier("PortfolioCell") as! PortfolioCell
		cell.username.text = self.portfolios[index].username
		cell.title.text = self.portfolios[index].name
		cell.descriptionLabel.text = self.portfolios[index].description
		cell.photoCount.text = String(self.portfolios[index].num_pic)
		cell.date.text = NSDateFormatter.localizedStringFromDate(self.portfolios[index].date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.selectedPortfolio = self.portfolios[indexPath.row]
		if let vc = self.parentVC {
			vc.performSegueWithIdentifier("MeOpenView", sender: vc)
		}
	}
}