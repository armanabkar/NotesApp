//
//  ViewController.swift
//  NotesApp
//
//  Created by Arman Abkar on 7/2/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var label: UILabel!
    
    var notes: [Note] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        
        title = "Notes"
    }
    
    @IBAction func didTapNewNote() {
        guard let viewController = storyboard?.instantiateViewController(identifier: "new") as? EntryViewController else {
            return
        }
        
        viewController.title = "New Note"
        viewController.navigationItem.largeTitleDisplayMode = .never
        viewController.completion = { noteTitle, note in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                let newNote = Note(title: noteTitle, note: note)
                self.notes.append(newNote)
                self.label.isHidden = true
                self.table.isHidden = false
                self.table.reloadData()
            }
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].title
        cell.detailTextLabel?.text = notes[indexPath.row].note
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let viewController = storyboard?.instantiateViewController(identifier: "note") as? NoteViewController else {
            return
        }
        
        DispatchQueue.main.async {
            let note = self.notes[indexPath.row]
            viewController.navigationItem.largeTitleDisplayMode = .never
            viewController.title = "Note"
            viewController.noteTitle = note.title
            viewController.note = note.note
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}

