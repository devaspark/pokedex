//
//  Pokemon.swift
//  pokedex
//
//  Created by Rex Kung on 11/19/17.
//  Copyright © 2017 Rex Kung. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionText: String!
    private var _pokemonURL: String!
    private var _pokemonEvoURL: String!
    
    var description: String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var type: String {
        if _type == nil {
            _type = ""
        }
        return _type
    }
    
    var defense: String {
        if _defense == nil {
            _defense = ""
        }
        return _defense
    }
    
    var height: String {
        if _height == nil {
            _height = ""
        }
        return _height
    }
    
    var weight: String {
        if _weight == nil {
            _weight = ""
        }
        return _weight
    }
    
    var attack: String {
        if _attack == nil {
            _attack = ""
        }
        return _attack
    }

    var nextEvolutionText: String {
        if _nextEvolutionText == nil {
            _nextEvolutionText = ""
        }
        return _nextEvolutionText
    }
    
    var nextEvoText: String {
        if _nextEvolutionText == nil {
            _nextEvolutionText = ""
        }
        return _nextEvolutionText
    }
    
    var name: String {
        
        return _name
    }
    
    var pokedexId: Int {
        
        return _pokedexId
    }
    
    init(name: String, pokedexId: Int) {
        
        self._name = name
        self._pokedexId = pokedexId
        
        self._pokemonURL="\(URL_BASE)\(URL_POKEMON)\(self.pokedexId)/"
        self._pokemonEvoURL="\(URL_BASE)\(URL_EVOLVE)\(self.pokedexId)/"
        
    }
    
    func downloadPokemonDetail(completed: @escaping DownloadComplete) {
        Alamofire.request(_pokemonURL).responseJSON { (response) in
            
            if let dict = response.result.value as? Dictionary<String, AnyObject> {
                
                print("do i get here")
                if let pokeName = dict["name"] as? String {
                    self._name = pokeName
                }

                if let pokedexID = dict["id"] as? Int {
                    self._pokedexId = pokedexID
                }
                
                
                if let stats = dict["stats"] as? [Dictionary<String, AnyObject>] {
                    if let defense = stats[1]["base_stat"] as? Int {
                        self._defense = "\(defense)"
                    }
                    
                    if let attack = stats[2]["base_stat"] as? Int {
                        self._attack = "\(attack)"
                    }
                }
            
                if let weight = dict["weight"] as? Int {
                    self._weight = "\(weight)"
                }

                if let height = dict["height"] as? Int {
                    self._height = "\(height)"
                }
                
                if let types = dict["types"] as? [Dictionary<String, AnyObject>], types.count > 0 {
                    if let type = types[0]["type"] as? Dictionary<String, String> {
                        if let typePoke = type["name"] {
                            self._type = typePoke.capitalized
                        }
                    }
                    
                    if types.count > 1 {
                        for x in 1..<types.count {
                            if let type = types[x]["type"] as? Dictionary<String, String> {
                                if let typePoke = type["name"] {
                                    self._type! += "/\(typePoke.capitalized)"
                                }
                            }
                        }
                    }
                    
                    print(self._type)
                    
                } else {
                    self._type = ""
                }
            
            }
            completed()
            
        }
        
        Alamofire.request(_pokemonEvoURL).responseJSON { (response) in
            if let evoDict = response.result.value as? Dictionary<String, AnyObject> {
                if let chain = evoDict["chain"] as? Dictionary<String, AnyObject> {
                    if let evolvesTo = chain["evolves_to"] as? [Dictionary<String, AnyObject>] {
                        if let species = evolvesTo[0]["species"] as? Dictionary<String, AnyObject> {
                            if let evoName = species["name"] as? String {
                                self._nextEvolutionText = evoName
                            }
                        }
                    }
                }
            }
            completed()
            
        }
        
        
    }
}
