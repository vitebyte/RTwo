//
//  ProfileViewController.swift
//  DigitalEcoSystem
//
//  Created by Narender Kumar on 04/05/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {

    //MARK: - View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        super.addRightBarButton(withImageName: Constants.BarButtonItemImage.MoreWhiteColor)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
