//
//  NoteViewController.swift
//  Notes2
//
//  Created by alex surmava on 28.01.25.
//
import UIKit

protocol NoteViewControllerDelegate: AnyObject {
    func didSaveNote(_ note: Note2)
    func didChangeNote()
}

class NoteViewController: UIViewController {
    
    weak var delegate: NoteViewControllerDelegate?
    private var note: Note2?
    private var isNewNote: Bool
    private var isLocked: Bool = false
    private var isFavourite: Bool = false
    
    private let grayView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter title"
        textField.font = UIFont.boldSystemFont(ofSize: 18)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        return textView
    }()
    
    private let lockImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "lock.fill"))
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        
        if let note = note {
            titleTextField.text = note.title
            descriptionTextView.text = note.text
            isLocked = note.locked
            isFavourite = note.favourite
            if isLocked{showLock(true)}
        }
    }
    
    private func showLock(_ show: Bool){
        descriptionTextView.isHidden = show
        lockImageView.isHidden = !show
        titleTextField.isEnabled = !show
    }
    
    init(note: Note2? = nil) {
        self.note = note
        self.isNewNote = (note == nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        view.addSubview(grayView)
        grayView.addSubview(titleTextField)
        grayView.addSubview(descriptionTextView)
        grayView.addSubview(lockImageView)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(showActions))
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: "slider.horizontal.3")
        
        navigationItem.title = isNewNote ? "New Note" : "Edit Note"
        lockImageView.isHidden = true

        NSLayoutConstraint.activate([
            grayView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            grayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            grayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            grayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            lockImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lockImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            lockImageView.heightAnchor.constraint(equalToConstant: 50),
            lockImageView.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc
    private func showActions() {
        self.saveNote()
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let titleForFavourites = isFavourite ? "Remove from favourites" : "Add to favourites"
        
        actionSheet.addAction(UIAlertAction(title: titleForFavourites, style: .default, handler: { _ in
            if self.isFavourite {
                self.note?.favourite = false
                self.isFavourite = false
            } else {
                self.note?.favourite = true
                self.isFavourite = true
            }
            self.saveNote()
        }))
        
        let titleForLock = isLocked ? "Unlock" : "Lock"
       
        actionSheet.addAction(UIAlertAction(title: titleForLock, style: .default, handler: { _ in
            if self.isLocked {
                self.unlock()
            } else {
                self.lock()
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc
    private func lock(){
        let alert = UIAlertController(title: "Lock Note", message: "Enter 6 digit password to lock note", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.keyboardType = .numberPad
            textField.isSecureTextEntry = true
            textField.textAlignment = .center
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { _ in
                if let text = textField.text, text.count > 6 {
                    textField.text = String(text.prefix(6))
                }
            }
        }
        
        let lockAction = UIAlertAction(title: "Lock", style: .default) { _ in
            if let password = alert.textFields?.first?.text, password.count == 6 {
                self.note?.locked = true
                self.note?.password = Int64(password) ?? 0
                self.saveNote()
                self.showLock(true)
                self.isLocked = true
            } else {
                self.showInvalidPasswordLengthAlert()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(lockAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showInvalidPasswordLengthAlert() {
        let invalidAlert = UIAlertController(title: "Invalid Password", message: "Password must be exactly 6 digits.", preferredStyle: .alert)
        invalidAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(invalidAlert, animated: true)
    }
    
    @objc
    private func unlock(){
        let alert = UIAlertController(title: "Unlock Note", message: "Enter your 6 digit password to unlock note", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.keyboardType = .numberPad
            textField.isSecureTextEntry = true
            textField.textAlignment = .center
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { _ in
                if let text = textField.text, text.count > 6 {
                    textField.text = String(text.prefix(6))
                }
            }
        }
        
        let unlockAction = UIAlertAction(title: "unlock", style: .default) { _ in
            if let password = alert.textFields?.first?.text, password.count == 6 && (self.note?.password == Int64(password)){
                self.note?.locked = false
                self.saveNote()
                self.showLock(false)
                self.isLocked = false
            } else {
                self.showInvalidPasswordAlert()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(unlockAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showInvalidPasswordAlert() {
        let invalidAlert = UIAlertController(title: "Invalid Password", message: "Incorrect password.", preferredStyle: .alert)
        invalidAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(invalidAlert, animated: true)
    }
    
    
    @objc
    private func saveNote() {
        let context = DBmanager.shared.persistentContainer.viewContext
        if note == nil {
            note = Note2(context: context)
            note?.color = Int64.random(in: 0..<11)
            note?.locked = false
            note?.favourite = false
        }
        note?.title = titleTextField.text ?? ""
        note?.text = descriptionTextView.text ?? ""
        
        do {
            try context.save()
            if(isNewNote){
                delegate?.didSaveNote(note!)
                isNewNote = false
            } else {
                delegate?.didChangeNote()
            }
        } catch {
            print(error)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveNote()
    }
    
}


