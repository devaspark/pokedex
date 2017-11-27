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
    private var _nextEvolutionName: String!
    private var _nextEvolutionID: String!
    private var _nextEvolutionLevel: String!
    private var _pokemonURL: String!
    private var _pokemonEvoURL: String!
    private var _pokemonDesURL: String!
    
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
    
    var nextEvolutionLevel: String {
        if _nextEvolutionLevel == nil {
            _nextEvolutionLevel = ""
        }
        return _nextEvolutionLevel
    }
    
    var nextEvolutionId: String {
        if _nextEvolutionID == nil {
            _nextEvolutionID = ""
        }
        return _nextEvolutionID
    }

    var nextEvolutionText: String {
        if _nextEvolutionText == nil {
            _nextEvolutionText = ""
        }
        return _nextEvolutionText
    }
    
    var nextEvolutionName: String {
        if _nextEvolutionName == nil {
            _nextEvolutionName = ""
        }
        return _nextEvolutionName
    }
    
    var name: String {
        if _name == nil {
            _name = ""
        }
        
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
        self._pokemonDesURL="\(URL_BASE)\(URL_DESCRIPTION)\(self.pokedexId)/"
        
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
        
        Alamofire.request(_pokemonDesURL).responseJSON { (response) in
            if let desDict = response.result.value as? Dictionary<String, AnyObject> {
                if let flavorTextEntries = desDict["flavor_text_entries"] as? [Dictionary<String, AnyObject>] {
                    if flavorTextEntries.count > 1 {
                        if let flavorText = flavorTextEntries[flavorTextEntries.count-1]["flavor_text"] as? String {
                            self._description = flavorText
                        }
                    } else {
                        if let flavorText = flavorTextEntries[0]["flavor_text"] as? String {
                            self._description = flavorText
                        }
                    }
                }
                //evolution info get
                if let evoChain = desDict["evolution_chain"] as? Dictionary<String, AnyObject> {
                    
                    //go to evo chain api
                    if let evoChainURL = evoChain["url"] as? String {
                    
                        Alamofire.request(evoChainURL).responseJSON { (response) in
                            if let evoDict = response.result.value as? Dictionary<String, AnyObject> {
                                if let chain = evoDict["chain"] as? Dictionary<String, AnyObject> {
                                    // call getChainName
                                    self._nextEvolutionName = self.getChainName(chain, pokeName: self._name).capitalized
                                }
                            }
                            completed()
                            
                        }
                        //end alamofire
                    }
                }
            
            }
            completed()
        }
        
        
    }
    
    func getChainName(_ dictionary: Dictionary<String, AnyObject>, pokeName: String) -> String {
        var result: String = "nothing happened"
        if let species = dictionary["species"] as? Dictionary<String, AnyObject> {
            if let dictPokeName = species["name"] as? String {
                if dictPokeName == pokeName {
                    //if the same, let's take a look at next evo, if exist
                    if let evoTo = dictionary["evolves_to"] as? [Dictionary<String, AnyObject>], evoTo.count > 0 {
                        //If there is actually a next evolution, we pass back the next evo name
                        if let evoToSpecies = evoTo[0]["species"] as? Dictionary<String, String> {
                            if let evoToSpeciesName = evoToSpecies["name"] {
                                
                                //grabbing next evo id
                                if let evoToSpeciesURL = evoToSpecies["url"] {
                                    let newStr = evoToSpeciesURL.replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon-species/", with: "")
                                    let nextEvoId = newStr.replacingOccurrences(of: "/", with: "")
                                    self._nextEvolutionID = nextEvoId
                                    
                                    
                                    //grabbing next level info
                                    if let evoDetails = evoTo[0]["evolution_details"] as? [Dictionary<String, AnyObject>] {
                                        if let minLevel = evoDetails[0]["min_level"] as? Int {
                                            self._nextEvolutionLevel = "\(minLevel)"
                                        }
                                    } else {
                                        self._nextEvolutionLevel = ""
                                    }
                                }
                                print(self.nextEvolutionName)
                                print(self.nextEvolutionId)
                                print(self.nextEvolutionLevel)
                                return evoToSpeciesName
                            }
                        }
                    } else {
                        // no next evolution
                        return pokeName
                    }
                } else {
                    //not the same name, go one level deeper
                    if let nextLevel = dictionary["evolves_to"] as? [Dictionary<String, AnyObject>] {
                        result = getChainName(nextLevel[0], pokeName: pokeName)
                    }
                }
            }
        }
        return result
    }
}
