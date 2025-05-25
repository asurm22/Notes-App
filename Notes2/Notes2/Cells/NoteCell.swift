//
//  NoteCell.swift
//  Notes2
//
//  Created by alex surmava on 28.01.25.
//

import UIKit

class NoteCell: UICollectionViewCell {
    
    @IBOutlet private var title: UITextField!
    @IBOutlet private var text: UITextView!
    @IBOutlet private var view: UIView!
    @IBOutlet private var lock: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        title.borderStyle = .none
        
    }
    
    func configure(with note: Note2){
        title.text = note.title
        text.text = note.text
        view.backgroundColor = colors[Int(note.color)].withAlphaComponent(0.3)
        view.layer.cornerRadius = 8
        text.isHidden = false
        lock.isHidden = true
        if note.locked{
            text.isHidden = true
            lock.isHidden = false
        }
    }
    
    private let colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.magenta,
                          UIColor.orange, UIColor.brown, UIColor.cyan, UIColor.gray, UIColor.purple]
    
    
}
