//
//  ExternalSortService.swift
//  ExternalSortApp
//
//  Created by Jackson  on 12.12.2021.
//

import Foundation

final class ExternalSortService {
    
    private let firstFileIndex = 0
    private var secondFileIndex = 1
    private var sortedArraySize = 10
    
    // MARK: -
    
    private var sortingNodes: [SortingNode] = []
    
    // MARK: -
    
    let fileService: FileService
    private let originData: [String]
    
    /// Dla naszego przykładu stworzymy sobie rozmiar RAM (max ilość liczb jaka może posortować nasza pamięć)...
    private let RAM_SIZE = 5
    
    private var INPUT_DATA_SIZE: Int?
    
    // MARK: - INITIALIZATING
    
    /// Dla naszego przykładu skorzystamy się danymi w postaci tablicy z liczbami...
    init(fileService: FileService, data: [String]) {
        self.fileService = fileService
        self.originData = data
        
        /// Dla przykładu aktualny rozmiar danych == długości tablicy...
        self.INPUT_DATA_SIZE = data.count
    }
    
    // MARK: - DATA CREATING
    func createSortNodes(block: () -> Void) {
        let timer = ParkBenchTimer()

        guard let INPUT_DATA_SIZE = INPUT_DATA_SIZE else {
            return
        }

        if INPUT_DATA_SIZE < RAM_SIZE {
            
        } else {
            let subfilesCount = INPUT_DATA_SIZE / RAM_SIZE
            var subfileIndex = 0
            var elementIndex = 0
            var sectionCapacity = 0
            
            while subfileIndex <= subfilesCount - 1 {
                var dataList = [Int]()
                
                while elementIndex <= sectionCapacity + RAM_SIZE {
                    guard let element = Int(originData[elementIndex]) else {
                        return
                    }
                    dataList.append(element)
                    if elementIndex == sectionCapacity + RAM_SIZE {
                        sectionCapacity += RAM_SIZE
                        break
                    }
                    elementIndex += 1
                }
                
                let sortNode = SortingNode(
                    fileName: "sort_file_\(subfileIndex)",
                    dataList: dataList,
                    currentIndex: 0)
                
                sortingNodes.append(sortNode)
                subfileIndex += 1
            }
        }
        
        writeSortNodesToFiles()
        block()
        
        print("\nData was created for \(timer.stop()) seconds.")
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
    func sortStep(_ timer: ParkBenchTimer) {
        var array0 = getData(fromFile: secondFileIndex)
        var array1 = getData(fromFile: firstFileIndex)
        
        let sortedData = scaleMergeSort(&array0, &array1)
        
        delete(file: firstFileIndex)
        delete(file: secondFileIndex)
        
        create(file: sortingNodes[firstFileIndex].fileName, stringData: sortedData.map { String($0) }.joined(separator: "\n"))
                
        secondFileIndex += 1
        
        guard secondFileIndex != sortingNodes.count else {
            print("Sorting was done for \(timer.stop()) seconds.")
            return
        }
        
        /// KONTYNUACJA SORTOWANIA PRZEZ REKURENCJE
        sortedArraySize += RAM_SIZE
        sortStep(timer)
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
