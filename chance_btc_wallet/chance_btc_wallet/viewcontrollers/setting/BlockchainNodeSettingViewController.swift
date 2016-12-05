//
//  BlockchainNodeSettingViewController.swift
//  chance_btc_wallet
//
//  Created by Chance on 2016/12/2.
//  Copyright © 2016年 chance. All rights reserved.
//

import UIKit

class BlockchainNodeSettingViewController: BaseViewController {
    
    @IBOutlet var tableViewNodes: UITableView!
    
    var nodes: [BlockchainNode] = BlockchainNode.allNodes    //全部节点列表
    var selectedNode = CHWalletWrapper.selectedBlockchainNode

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Blockchain Node".localized()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


// MARK: - 实现表格委托方法
extension BlockchainNodeSettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nodeCell = "nodeCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: nodeCell)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: nodeCell)
        }
        let node = self.nodes[indexPath.row]
        cell?.textLabel?.text = node.name
        cell?.detailTextLabel?.text = node.url
        //显示已选
        if node == self.selectedNode {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let node = self.nodes[indexPath.row]
        CHWalletWrapper.selectedBlockchainNode = node
        self.selectedNode = node
        //let cell = tableView.cellForRow(at: indexPath)
        tableView.reloadData()
    }
}
