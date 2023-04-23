//
//  ObservableWrapper.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 22.04.2023.
//

@propertyWrapper
class Observable<Value> {
    typealias Listener = ((Value) -> Void)
    
    private var onChange: Listener?
    
    var wrappedValue: Value {
        didSet {
            onChange?(wrappedValue)
        }
    }
    
    var projectedValue: Observable {
        return self
    }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    func bind(_ action: Listener?) {
        self.onChange = action
    }
}
