//
//  ViewController.swift
//  Notes2
//
//  Created by alex surmava on 28.01.25.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private var addButton: UIButton!
    @IBOutlet private var favouriteButton: UIButton!
    private var collectionView: UICollectionView!
    private let dbContext = DBmanager.shared.persistentContainer.viewContext
    private var notes: [Note2] = []
    private var showingFavourites: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchNotes()
        configureAddButton()
        configureFavouriteButton()
    }
    
    
    private func fetchNotes() {
        let request = Note2.fetchRequest()
        
        do {
            notes = try dbContext.fetch(request)
            collectionView.reloadData()
        } catch {
            print(error)
        }
    }
    
    private func configureCollectionView() {
        let layout = PinterestLayout()
        layout.delegate = self
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "NoteCell", bundle: nil), forCellWithReuseIdentifier: "NoteCell")

    
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress)))
        
        collectionView.backgroundColor = .lightGray.withAlphaComponent(0.3)
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc
    private func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            let point = gesture.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: point) {
                let note = notes[indexPath.row]
                if(note.locked){
                    let alert = UIAlertController(
                        title: "",
                        message: "This note is locked, unlock it to delete it.",
                        preferredStyle: .actionSheet
                    )
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    present(alert, animated: true)
                } else {
                    let alert = UIAlertController(
                        title: "",
                        message: "Want to delete this note?",
                        preferredStyle: .actionSheet
                    )
                    
                    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [unowned self] _ in
                        dbContext.delete(note)
                        try? dbContext.save()
                        if showingFavourites {
                            fetchFavourites()
                        } else {
                            fetchNotes()
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    present(alert, animated: true)
                }
            }
        }
    }
    
    private func configureAddButton() {
        addButton.addTarget(self, action: #selector(handleAddNote), for: .touchUpInside)
    }
    
    @objc
    private func handleAddNote() {
        let noteViewController = NoteViewController(note: nil)
        noteViewController.delegate = self
        navigationController?.pushViewController(noteViewController, animated: true)
    }
    
    private func configureFavouriteButton() {
        favouriteButton.addTarget(self, action: #selector(handleFavourite), for: .touchUpInside)
    }
    
    @objc
    private func handleFavourite() {
        showingFavourites.toggle()
        if showingFavourites {
            favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            fetchFavourites()
        } else {
            favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            fetchNotes()
        }
    }
    
    private func fetchFavourites(){
        let request = Note2.fetchRequest()
        let predicate = NSPredicate(format: "favourite == true")
        request.predicate = predicate
        do {
            notes = try dbContext.fetch(request)
            collectionView.reloadData()
        } catch {
            print(error)
        }
    }


}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCell", for: indexPath)
        if let noteCell = cell as? NoteCell {
            let note = notes[indexPath.row]
            noteCell.configure(with: note)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        let noteViewController = NoteViewController(note: note)
        noteViewController.delegate = self
        navigationController?.pushViewController(noteViewController, animated: true)
    }
    
    
}

extension ViewController: NoteViewControllerDelegate {
    
    func didSaveNote(_ note: Note2) {
        notes.append(note)
        collectionView.reloadData()
    }
    
    func didChangeNote(){
        collectionView.reloadData()
    }
}

extension ViewController: PinterestLayoutDelegate {
    func textForItem(at indexPath: IndexPath) -> String {
        return notes[indexPath.item].text ?? ""
    }
    
    func titleForItem(at indexPath: IndexPath) -> String {
        return notes[indexPath.item].title ?? ""
    }
}

