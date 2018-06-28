//
//  PerformanceViewController.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 22/03/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit

class PerformanceViewController: BaseViewController {

    //MARK: - life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        super.navigationBarAppearanceBlack(navController: navigationController!)
        doInitialSetup()
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        handleLocalizeStrings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Helper Methods
    func doInitialSetup() {
        // super.addMoreLeftBarButton()
        super.addRightBarButton(withImageName: Constants.BarButtonItemImage.MoreWhiteColor)
    }

    func handleLocalizeStrings() {
        navigationItem.title = LocalizedString.shared.performanceTitleString
    }
}
