//
//  CollectionViewCell.swift
//  sud1
//
//  Created by Андрей Глухих on 21.02.2018.
//  Copyright © 2018 scapegoat. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var textField: UITextField!



    //@IBAction func changed(_ sender: Any) {

    //}

    
    @IBAction func edit(_ sender: UITextField) {
       
        let temp=Int(sender.accessibilityIdentifier!) ?? -1
        ViewController.findError(index:temp)
    }
}
