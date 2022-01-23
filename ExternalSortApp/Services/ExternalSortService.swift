//
//  ExternalSortService.swift
//  ExternalSortApp
//
//  Created by Jackson  on 12.12.2021.
//

import Foundation

final class ExternalSortService {
    
    private var firstFileIndex = 0
    private var secondFileIndex = 1
    private var sortedArraySize = 10
    
    // MARK: -
    
    private var sortingNodes: [SortingNode] = []
    
    // MARK: -
    
    let fileService: FileService
    private var originData: [String]
    
    /// Dla naszego przykładu stworzymy sobie rozmiar RAM (max ilość liczb jaka może posortować nasza pamięć)...
    private let RAM_SIZE = 5
    
    private var INPUT_DATA_SIZE = 0
    
    // MARK: - INITIALIZATING
    
    /// Dla naszego przykładu skorzystamy się danymi w postaci tablicy z liczbami...
    init(fileService: FileService, data: [String]) {
        self.fileService = fileService
        self.originData = data
        
        /// Dla przykładu aktualny rozmiar danych == długości tablicy...
        self.INPUT_DATA_SIZE = data.count
    }
    
    // MARK: - DATA CREATING
    
    func createSortNodes(finishNodeCreating: () -> ()) {
        var elements: [Int] = []
        var nodeIndex = 0
        while originData != [] {
            if elements.count == RAM_SIZE {
                
                sortingNodes.append(SortingNode(
                    fileName: "sort_file_\(nodeIndex)",
                    dataList: elements,
                    currentIndex: 0))
                elements = []
                nodeIndex += 1
                
            } else {
                elements.append(Int(originData.first!)!)
                originData.removeFirst()
            }
        }
        
        if !elements.isEmpty {
            sortingNodes.append(SortingNode(
                fileName: "sort_file_\(nodeIndex)",
                dataList: elements,
                currentIndex: 0))
            elements = []
            nodeIndex += 1
        }
        
        writeSortNodesToFiles()
        finishNodeCreating()
    }
    
    func cleanTrash(_ endBlock: (() -> ())? = nil) {
        fileService.cleanDirectory()
        endBlock?()
    }
    
    private func writeSortNodesToFiles() {
        fileService.cleanDirectory()
        sortingNodes.forEach { sortNode in
            sortNode.dataList.sorted().forEach {
                fileService.add(line: "\($0)\n", to: sortNode.fileName)
            }
        }
    }
    
    // MARK: -
    func sortStep(_ timer: ParkBenchTimer, _ completed: ((CFAbsoluteTime) -> ())? = nil) {
        
        var array0 = getData(fromFile: firstFileIndex)
        var array1 = getData(fromFile: secondFileIndex)
        
        let sortedData = scaleMergeSort(&array0, &array1)
        
        delete(file: firstFileIndex)
        delete(file: secondFileIndex)
        
        create(file: sortingNodes[firstFileIndex].fileName, stringData: sortedData.map { String($0) }.joined(separator: "\n"))
                
        secondFileIndex += 1
        
        guard secondFileIndex != sortingNodes.count else {
            print("\n|=============================================|")
            print("\n|Sorting was done for \(timer.stop()) seconds.")
            print("\n|=============================================|")
            completed?(timer.stop())
            return
        }
        
        sortedArraySize += RAM_SIZE
        sortStep(timer, completed)
    }
    
    // MARK: - MERGE SORT FUNCTION
    private func scaleMergeSort(_ array0: inout [Int], _ array1: inout [Int]) -> [Int] {
        var sortedArray: [Int] = []
        var currentIndex = 0
        
        while currentIndex < sortedArraySize {
            if let el0 = array0.first,
               let el1 = array1.first {
                if el0 > el1 {
                    sortedArray.append(el1)
                    array1.removeFirst()
                } else if el0 < el1 {
                    sortedArray.append(el0)
                    array0.removeFirst()
                } else {
                    sortedArray.append(el0)
                    array0.removeFirst()
                }
                currentIndex += 1
            } else if array0.isEmpty || array1.isEmpty {
                sortedArray += array0 + array1
                break
            }
        }
        return sortedArray
    }
    
    // MARK: - HELPING FUNCTIONS
    private func getData(fromFile index: Int) -> [Int] {
        guard let fileContent = fileService.read(
            file: sortingNodes[index].fileName) else {
                return []
            }
        let stringFileContent = fileContent.split(separator: "\n")
        return stringFileContent.map { Int($0)! }
    }
    
    private func delete(file fileIndex: Int) {
        do {
           try fileService.delete(file: sortingNodes[fileIndex].fileName)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func create(file fileName: String, stringData: String) {
        fileService.create(file: fileName)
        fileService.write(string: stringData, to: fileName)
    }
}
