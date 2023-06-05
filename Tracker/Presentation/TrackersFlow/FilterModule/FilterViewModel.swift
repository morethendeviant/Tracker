//
//  FilterViewModel.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 04.06.2023.
//

import Foundation

protocol FiltersViewCoordination {
    var onFinish: ((Filter) -> Void)? { get set }
}

protocol FiltersViewModelProtocol {
    var filtersAmount: Int { get }
    var selectedFilterIndex: Int? { get }
    
    func filterFor(index: Int) -> String?
    func selectFilter(_ index: Int)
}

final class FilterViewModel: FiltersViewCoordination {
    var onFinish: ((Filter) -> Void)?
    
    private var filters: [Filter] = [.all, .today, .finished, .unfinished]
    private(set) var selectedFilterIndex: Int?
    
    init(selectedFilter: Filter) {
        self.selectedFilterIndex = filters.firstIndex(of: selectedFilter)
    }
}

extension FilterViewModel: FiltersViewModelProtocol {
    var filtersAmount: Int {
        filters.count
    }
    
    func filterFor(index: Int) -> String? {
        guard filters.indices ~= index else { return nil }
        return filters[index].description
    }
    
    func selectFilter(_ index: Int) {
        guard filters.indices ~= index else { return }
        onFinish?(filters[index])
    }
}
