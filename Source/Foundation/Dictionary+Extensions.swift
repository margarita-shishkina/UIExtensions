//
//  Dictionary+Extensions.swift
//
//  Created by Vladimir Kazantsev on 23.01.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

public extension Dictionary {

	init(_ elements: [Element]){
		self.init()
		for (k, v) in elements {
			self[k] = v
		}
	}
	
	func map<U>( _ transform: ( Value ) throws -> U ) throws -> [Key : U] {
		return Dictionary<Key, U>( try self.map { key, value in ( key, try transform( value )) } )
	}
	
	func map<T, U>(_ transform: (Key, Value) throws -> (T, U)) throws -> [T : U] {
		return Dictionary<T, U>( try self.map( transform ))
	}
	
	mutating func addEntriesFromDictionary<KeyType,ValueType>( _ dict: [KeyType: ValueType] ) {
		for ( key, value ) in dict {
			updateValue( value as! Value, forKey: key as! Key )
		}
	}
	
	subscript (key: Key, defaultValue: Value ) -> Value {
		if let value = self[ key ] {
			return value
		} else {
			return defaultValue
		}
	}
	func valueForKey<T>( _ key: Key, defaultValue: T ) -> T {
		if let value = self[ key ] as? T {
			return value
		} else {
			return defaultValue
		}
	}
}

public extension Dictionary where Value: OptionalType {

	/// Transforms dictionary with optional values to
	/// dictionary with values of the same but not optional type.
	/// All keys with `nil` values are dropped.
	var sanitized: [ Key: Value.Wrapped ] {

		var sanitizedDictionary: [ Key: Value.Wrapped ] = [:]

		self.forEach {
			if let value = $0.value.value { sanitizedDictionary[ $0.key ] = value }
		}

		return sanitizedDictionary
	}
}

public func + <K,V>( left: Dictionary<K,V>, right: Dictionary<K,V> ) -> Dictionary<K,V> {
	var map = left
	map.addEntriesFromDictionary( right )
	return map
}
