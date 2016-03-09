//
//  ViewController.swift
//  SMAudioRecorderDemo
//
//  Created by softman on 16/3/9.
//  Copyright © 2016年 softman123g. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SMAudioRecorderViewControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showDemoClick(sender: UIButton) {
        let audioRecorder = SMAudioRecorderViewController()
        audioRecorder.delegate = self
        presentViewController(audioRecorder, animated: true, completion: nil)
    }
    
    //MARK: delegate
    func audioRecorderFinishRecord(withFileURL fileURL: NSURL?) {
        if let f = fileURL {
            SMToast.showText("录音文件成功\n"+f.absoluteString, duration: 5)
        }
    }
}

