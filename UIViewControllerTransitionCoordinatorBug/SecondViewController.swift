//
//  SecondViewController.swift
//  UIViewControllerTransitionCoordinatorBug
//
//  Created by Kazuhiro Hayashi on 2018/09/17.
//  Copyright © 2018 kazuhiro hayashi. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        contentView.layer.cornerRadius = 150
//        contentView.backgroundColor = .blue
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        contentView.layer.cornerRadius = 0
//        contentView.backgroundColor = .red
//    }
//    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
