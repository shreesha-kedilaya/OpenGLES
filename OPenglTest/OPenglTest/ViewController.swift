//
//  ViewController.swift
//  OPenglTest
//
//  Created by Shreesha on 27/03/17.
//  Copyright © 2017 YML. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var customOpenglView: OPenGlView!
    override func viewDidLoad() {
        super.viewDidLoad()
        customOpenglView = OPenGlView(frame: view.bounds)
        view.addSubview(customOpenglView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        print("Recieved memory warning")
    }
}

