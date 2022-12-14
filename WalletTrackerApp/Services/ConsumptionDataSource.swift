//
//  ConsumptionDataSource.swift
//  WalletTrackerApp
//
//  Created by Клоун on 06.12.2022.
//

import UIKit

enum Section: String, CaseIterable {
    case travell = "Travell"
    case shopping = "Shopping"
    case rent = "Rent"
    case grocery = "Groceries"
}

class ConsumptionDataSource: UITableViewDiffableDataSource<Section, ConsumptionTypeModel> {
    private var consumptions: [ConsumptionType: [ConsumptionTypeModel]] = [:]
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionIdentifier(for: section)?.rawValue
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteConsumption(at: indexPath)
            guard tableView.numberOfRows(inSection: indexPath.section) == 0,
                  let sectionIdentifier = sectionIdentifier(for: indexPath.section) else { return }
            
            var snapshot = snapshot()
            snapshot.deleteSections([sectionIdentifier])
            
            apply(snapshot)
        }
    }
    
    func update() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ConsumptionTypeModel>()

        for section in Section.allCases {
            if let consumption = consumptions.values.first(where: { $0.first?.type.rawValue == section.rawValue }) {
                snapshot.appendSections([section])
                snapshot.appendItems(consumption)
                apply(snapshot)
            }
        }
    }
    
    func saveConsumption(_ consumption: ConsumptionTypeModel) {
        consumptions[consumption.type] == nil
        ? consumptions[consumption.type] = [consumption]
        : consumptions[consumption.type]?.append(consumption)
        
        update()
    }
    
    func deleteConsumption(at indexPath: IndexPath) {
        var snapshot = self.snapshot()
        if let consumption = itemIdentifier(for: indexPath) {
            snapshot.deleteItems([consumption])
            deleteConsumptionFromList(consumption)
            apply(snapshot)
        }
    }
    
    func deleteConsumptionFromList(_ consumption: ConsumptionTypeModel) {
        guard let key = consumptions.getKey(for: [consumption]),
              let index = consumptions[key]?.firstIndex(of: consumption) else { return }
        consumptions[key]?.remove(at: index)
        
        guard let _ = consumptions[key]?.isEmpty else { return }
        consumptions.removeValue(forKey: key)
    }
    
    func filterConsumptionsByPrice() {
        for key in consumptions.keys {
            consumptions[key] = consumptions[key]?.sorted(by: { Int($0.price) ?? 0 < Int($1.price) ?? 0 })
        }
        
        update()
    }
    
    func isEmptyConsumptionList() -> Bool {
        consumptions.isEmpty
    }
    
    func getCircleSegments() -> [(CGFloat, UIColor)] {
        consumptions.keys.map { (CGFloat(consumptions[$0]?.count ?? 0), .getColor(type: $0)) }
    }
}
