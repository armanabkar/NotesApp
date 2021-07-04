//
//  ViewController.swift
//  NotesApp
//
//  Created by Arman Abkar on 7/2/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var label: UILabel!
    
    var notes = [Note]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        
        title = "Notes"
        
        loadNotes()
        
        if !notes.isEmpty {
            label.isHidden = true
            table.isHidden = false
        }
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
                let newNote = Note(context: self.context)
                newNote.title = noteTitle
                newNote.note = note
                self.notes.append(newNote)
                self.label.isHidden = true
                self.table.isHidden = false
                self.saveNotes()
            }
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func saveNotes() {
        do {
            try context.save()
        } catch {
            print("Error saving notes \(error)")
        }
        
        self.table.reloadData()
    }
    
    func loadNotes() {
        let request : NSFetchRequest<Note> = Note.fetchRequest()
        
        do{
            notes = try context.fetch(request)
        } catch {
            print("Error loading notes \(error)")
        }
        
        table.reloadData()
    }
    
}

// MARK: - Table View

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            viewController.title = note.title
            viewController.noteTitle = note.title ?? ""
            viewController.note = note.note ?? ""
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = notes[indexPath.row]
            context.delete(commit)
            notes.remove(at: indexPath.row)
            table.deleteRows(at: [indexPath], with: .fade)
            
            self.saveNotes()
        }
    }
    
}
