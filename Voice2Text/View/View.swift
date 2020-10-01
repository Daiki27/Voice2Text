//
//  View.swift
//  Voice2Text
//
//  Created by 樋口大樹 on 2020/10/01.
//  Copyright © 2020 樋口大樹. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

//仕様書.
protocol My_ViewDelegate: AnyObject {
    func recordButtonTapped() //change camera position (front or back).
}

//final : サブクラスを定義させない.
final class CustomView: UIView {
    
    weak var delegate  : My_ViewDelegate?
    var recordButton   = UIButton()   //preview camera image
    var Voice2TextView = UITextView() //take image.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        set_desgin()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @IBAction func RECORD_BUTTON_TAPPED(_ sender : Any){
        delegate?.recordButtonTapped()
    }
}

extension CustomView{
    func set_desgin(){
        //info of parts and view.
        let view_width         = Double(self.frame.size.width)
        let view_height        = Double(self.frame.size.height)
        let Record_Buttun_Size = view_width/4.0
        
        //set record button.
        recordButton = { () -> UIButton in
            let button = UIButton()
            button.frame = CGRect(
                x: view_width/2-Record_Buttun_Size/2,
                y: view_height*3/4,
                width:  Record_Buttun_Size,
                height: Record_Buttun_Size)
            button.addTarget(self, action: #selector(RECORD_BUTTON_TAPPED(_:)), for: UIControl.Event.touchUpInside)
            button.backgroundColor   = .white
            button.layer.borderColor = UIColor.red.cgColor
            button.layer.borderWidth = 4.5
            button.layer.cornerRadius = CGFloat(Record_Buttun_Size/2)
            return button
        }()
        self.addSubview(recordButton)
        
        Voice2TextView = {()->UITextView in
            let textview = UITextView()
            textview.frame = CGRect(x: view_width/4, y: view_height/4, width: view_width*2/4, height: view_height*2/4)
            textview.backgroundColor = .lightGray
            textview.textAlignment   = .center
            return textview
        }()
        self.addSubview(Voice2TextView)
    }
}
