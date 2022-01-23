//
//  ViewController.swift
//  ExternalSortApp
//
//  Created by Jackson  on 12.12.2021.
//

import UIKit

class MainViewController: UIViewController {
    
    private var sortService: ExternalSortService?
    
    // MARK: - @IBOutlet
    
    @IBOutlet private weak var elementsCountTF: UITextField!
    @IBOutlet private weak var rangeTF: UITextField!
    
    // MARK: - @IBActions
    
    @IBAction private func clean(_ sender: UIButton) {
        sortService?.cleanTrash { [weak self] in
            let alertController = UIAlertController(
                title: "Data was cleaned. 🧹",
                message: "App is ready for new data 💪",
                preferredStyle: .alert)
            self?.present(alertController, animated: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction private func createDataAndWriteToFiles(_ sender: UIButton) {
        
        guard let maxNum = Int(rangeTF.text?.split(separator: ",").last ?? "10"),
              let minNum = Int(rangeTF.text?.split(separator: ",").first ?? "0"),
              let elementsCount = elementsCountTF.text else { return }
                
        let data = randomNumbers(
            amount: Int(elementsCount) ?? 10,
            min: minNum,
            max: maxNum)
        
        let sortService = ExternalSortService(
            fileService: FileService(),
            data: data)
                
        sortService.createSortNodes { [weak self] in
            let alertController = UIAlertController(
                title: "Data is ready for sort. ✅",
                message: "",
                preferredStyle: .alert)
            self?.present(alertController, animated: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            })
        }
        
        self.sortService = sortService
        guard let url = self.sortService?.fileService.rootUrl?.absoluteURL else {
            return
        }
        print(url)
    }
    
    @IBAction private func startSorting(_ sender: UIButton) {
        sortService?.sortStep(ParkBenchTimer())
    }
    
    // MARK: - MAIN ACTIONS
    private func randomNumbers(amount: Int, min: Int, max: Int) -> [String] {
        var array = [String]()
        var index = 0
        while index <= amount - 1 {
            array.append(String(Int.random(in: min...max)))
            index += 1
        }
        return array
    }
}
