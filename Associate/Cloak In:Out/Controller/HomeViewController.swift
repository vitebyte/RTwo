//
//  HomeViewController.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 22/03/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper
import CoreStore

class HomeViewController: BaseViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!

    //MARK: - View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        doInitialSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        // super.addMoreLeftBarButton()
        super.addRightBarButton(withImageName: Constants.BarButtonItemImage.MoreWhiteColor)
        handleLocalizeStrings()
    }

    // MARK: - Helper Methods
    func doInitialSetup() {
        showLogOutonNavigationBar()
        super.navigationBarAppearanceBlack(navController: navigationController!)
        setCircularProfileImageView()
        if let _ = UserManager.shared.activeUser.profileImg {
            let imagUrl: String = Constants.ImageUrl.SmallImage + UserManager.shared.activeUser.profileImg!
            profilePicImageView.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "defaultPic.png"))
        } else {
            profilePicImageView.image = UIImage.init(named: "defaultPic.png")
        }
        nameLabel.text = UserManager.shared.activeUser.userName?.capitalizingFirstLetter()
    }

    func handleLocalizeStrings() {
        navigationItem.title = LocalizedString.shared.profileSubtitleString
        welcomeLabel.text = LocalizedString.shared.welcomeString
    }

    func setCircularProfileImageView() {
        view.layoutIfNeeded()
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.size.width / 2
        profilePicImageView.layer.masksToBounds = true
        profilePicImageView.contentMode = .scaleAspectFill
    }

    func showLogOutonNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: LocalizedString.shared.buttonLogoutTitle, style: UIBarButtonItemStyle.plain, target: self, action: #selector(buttonLogoutAction))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }

    // MARK: - Button Actions
    func buttonLogoutAction() {
        let alertController = UIAlertController(title: nil, message: LocalizedString.shared.logoutTitle, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString(LocalizedString.shared.buttonConfirmTitle, comment: LocalizedString.shared.buttonConfirmTitle), style: UIAlertActionStyle.destructive, handler: { (_) -> Void in
            // Handle Logout
            self.userLogout()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString(LocalizedString.shared.buttonCancelTitle, comment: LocalizedString.shared.buttonCancelTitle), style: UIAlertActionStyle.cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

//MARK: API calls
extension HomeViewController {

    func userLogout() {
        UserManager.shared.activeUser.performLogout { (success, strMessage) -> Void in
            if success {
                CoreDataManager.flushCachedData()
                AppDelegate.presentRootViewController()
            } else {
                self.showAlertViewWithMessage(LocalizedString.shared.FAILURE_TITLE, message: strMessage!,true)
            }
        }
    }
}
