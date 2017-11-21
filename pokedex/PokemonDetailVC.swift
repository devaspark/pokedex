//
//  PokemonDetailVC.swift
//  pokedex
//
//  Created by Rex Kung on 11/20/17.
//  Copyright © 2017 Rex Kung. All rights reserved.
//

import UIKit

class PokemonDetailVC: UIViewController {

    var pokemon: Pokemon!
    
    @IBOutlet weak var nameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLbl.text = pokemon.name
    }


}
