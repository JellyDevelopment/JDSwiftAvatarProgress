//
//  ViewController.swift
//  JDSwiftAvatarProgress
//
//  Created by David López on 10/20/2015.
//  Copyright (c) 2015 David López. All rights reserved.
//

import UIKit
import JDSwiftAvatarProgress

class ViewController: UIViewController {

    @IBOutlet weak var avatarImgView: JDAvatarProgress!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.avatarImgView.image = UIImage(named: "empty_avatar")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loadAvatar(sender: AnyObject) {
        
        self.avatarImgView.setImageWithURL(NSURL(string: "http://3.bp.blogspot.com/-k-0O0FocJ2I/TyWbextRGlI/AAAAAAAACqo/GuPx0RH7PcY/s1600/Fondo+Pantalla.jpg")!,
            placeholder: nil,
            progressBarColor: UIColor.orangeColor(),
            progressBarLineWidth: JDAvatarDefaultProgressBarLineWidth,
            borderColor:nil,
            borderWidth: JDAvatarDefaultBorderWidth,
            completion: { (image, error) -> Void in
                
                print("image => \(image)")
                print("error => \(error)")
                print("------------------")
        })

    }
}

