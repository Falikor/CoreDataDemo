//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by 18992227 on 05.07.2021.
//

import CoreData
import UIKit

final class TaskListViewController: UITableViewController {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private static let cellId = "cell"
    private var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellId)
        tableView.dataSource = self
        setupNavigationBar()
        fetchData()
        tableView.reloadData()
        

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchData()
        tableView.reloadData()
    }

    private func setupNavigationBar() {
        title = "Task List"

        navigationController?.navigationBar.prefersLargeTitles = true

        // Navigation bar appeareance
        let navBarAppereance = UINavigationBarAppearance()
        navBarAppereance.configureWithOpaqueBackground()

        navBarAppereance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppereance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navBarAppereance.backgroundColor = UIColor(
            red: 21 / 255,
            green: 101 / 255,
            blue: 192 / 255,
            alpha: 194 / 255
        )

        navigationController?.navigationBar.standardAppearance = navBarAppereance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppereance

        // Add button to nav bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )

        navigationController?.navigationBar.tintColor = .white
    }

    @objc private func addNewTask() {
        //let newTaskVC = NewTaskViewController()
        //newTaskVC.modalPresentationStyle = .fullScreen
        //present(newTaskVC, animated: true)

        showAlert(with: "New Task", message: "What do you want to enter?")
    }

    private func fetchData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error {
            print(error)
        }
    }
}

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellId, for: indexPath)
        let task = tasks[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = tasks[indexPath.row]
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            let alert = UIAlertController(title: "Edit task", message: "Edit new task", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.title
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else { return }
                self?.updateItem(item: item, newName: newName)
            }))
            self.present(alert, animated: true)

        }))
        
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deletItem(item: item)
        }))
        
        self.present(sheet, animated: true)
    
    }
    
// alter save new task
    private func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let saveAction = UIAlertAction(
            title: "Save",
            style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }

            self.createItem(name: task)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}


// Core Data
extension TaskListViewController {
    private func getAllitems() {
        do {
            tasks = try context.fetch(Task.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            
        }

    }
    
    private func createItem(name: String) {
        let newItem = Task(context: context)
        newItem.title = name
        do {
            try context.save()
            getAllitems()
        } catch {
            
        }
    }
    
    private func deletItem(item: Task) {
        context.delete(item)
        do {
            try context.save()
            getAllitems()
        } catch {
            
        }
        
    }
    
    private func updateItem(item: Task, newName: String) {
        item.title = newName
        do {
            try context.save()
            getAllitems()
        } catch {
            
        }
    }
}
