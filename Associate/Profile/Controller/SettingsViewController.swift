//
//  SettingsViewController.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 30/03/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit

let HEIGHT_CELL: CGFloat = 51.0

private enum SelectedCell: Int {
    case editProfilePhoto = 0, viewOnboarding, changeLanguage, logOut
}

class SettingsViewController: UIViewController {

    //MARK: - Variables
    public let cellIdentifier = "CellComment"
    public var contentArray = ["Edit Profile Photo", "View Onboarding", "Change Language", "Log Out"]

    // MARK: - IBOutlets
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var settingsTableView: UITableView!

    //MARK: - View lifecyle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_: Bool) {
        doInitalSetup()
    }

    // MARK: - Helper Methods
    func doInitalSetup() {
        navigationController?.isNavigationBarHidden = true
        settingsTableView.layer.cornerRadius = 2.0
        cancelButton.layer.cornerRadius = 2.0
    }

    // MARK: - Button Actions

    @IBAction func cancelButtonTapped(_: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return contentArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell?
        cell?.textLabel?.text = contentArray[indexPath.row]
        cell?.textLabel?.textAlignment = .center
        cell?.textLabel?.font = UIFont.gothamMedium(15)
        return cell!
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case SelectedCell.editProfilePhoto.rawValue:
            moveToProfilePicViewControllerWithNavigation()

        case SelectedCell.viewOnboarding.rawValue:
            moveToWalkthroughViewControllerWithNavigation()

        case SelectedCell.changeLanguage.rawValue:
            moveToChooseLanguageViewControllerWithNavigation()

        case SelectedCell.logOut.rawValue:
            logoutTapped()
        default:
            cancelButtonTapped(UIButton.self)
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return HEIGHT_CELL
    }
}

// MARK: - API calls
extension SettingsViewController {

    func logoutTapped() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                UserManager.shared.activeUser.performLogout { (success, strMessage) -> Void in
                    if success {
                        AppDelegate.presentRootViewController()
                    } else {
                        self.showAlertViewWithMessage(LocalizedString.shared.FAILURE_TITLE, message: strMessage!,true)
                    }
                }

            })
        }
    }
}

// MARK: - Navigation Control

extension SettingsViewController: UIPopoverPresentationControllerDelegate {

    func moveToWalkthroughViewControllerWithNavigation() {
        let storyboard = UIStoryboard.mainStoryboard()
        let controller = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.WalkThroughIdentifier) as! WalkThroughViewController
        controller.isPresentingSelf = true
        controller.modalPresentationStyle = UIModalPresentationStyle.popover
        let popoverPresentationController = controller.popoverPresentationController
        popoverPresentationController?.delegate = self
        // result is an optional (but should not be nil if modalPresentationStyle is popover)
        if let _popoverPresentationController = popoverPresentationController {
            // set the view from which to pop up
            _popoverPresentationController.sourceView = view
            controller.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            let navBar = UINavigationController(rootViewController: controller)
            navigationController?.present(navBar, animated: true, completion: nil)
        }
    }

    func moveToProfilePicViewControllerWithNavigation() {
        let storyboard = UIStoryboard.mainStoryboard()
        let controller = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.ProfilePicIdentifier) as! ProfilePicViewController
        controller.isPresentingSelf = true
        controller.modalPresentationStyle = UIModalPresentationStyle.popover
        let popoverPresentationController = controller.popoverPresentationController
        popoverPresentationController?.delegate = self
        // result is an optional (but should not be nil if modalPresentationStyle is popover)
        if let _popoverPresentationController = popoverPresentationController {
            // set the view from which to pop up
            _popoverPresentationController.sourceView = view
            controller.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            let navBar = UINavigationController(rootViewController: controller)
            navigationController?.present(navBar, animated: true, completion: nil)
        }
    }

    func moveToChooseLanguageViewControllerWithNavigation() {
        let storyboard = UIStoryboard.mainStoryboard()
        let controller = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.ChooseLanguageIdentifier) as! ChooseLanguageViewController
        controller.isPresentingSelf = true
        controller.modalPresentationStyle = UIModalPresentationStyle.popover
        let popoverPresentationController = controller.popoverPresentationController
        popoverPresentationController?.delegate = self
        // result is an optional (but should not be nil if modalPresentationStyle is popover)
        if let _popoverPresentationController = popoverPresentationController {
            // set the view from which to pop up
            _popoverPresentationController.sourceView = view
            controller.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            let navBar = UINavigationController(rootViewController: controller)
            navigationController?.present(navBar, animated: true, completion: nil)
        }
    }
}
