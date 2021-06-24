//
//  ViewController.swift
//  FileDownLoader
//
//  Created by 영관 on 2018. 7. 26..
//  Copyright © 2018년 Ji Young-Kwan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var fileDownLoadPopup : FileDownLoadPopup?
    @IBOutlet weak var tfFileURL: UITextField!
    
    override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    @IBAction func sendRequest(_ sender: Any) {
        guard let urlStr = tfFileURL.text ,let url = URL.init(string: urlStr) else {
            return
        }
        
        let fileName = url.lastPathComponent
        fileDownLoadPopup = FileDownLoadPopup.init(url: urlStr, fileName: fileName)
        fileDownLoadPopup?.show()
    }
    
}

