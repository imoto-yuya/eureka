//
//  RandomizedExtraction.swift
//  eureka
//
//  Created by Yuya Imoto on 2018/05/14.
//  Copyright © 2018年 Yuya Imoto. All rights reserved.
//

import Foundation

class RandomizedExtraction {

    var cumulativeWeightList: [UInt32] = []

    init(_ listSize: Int) {
        var cumulativeWeight = 0
        for index in 0..<listSize {
            cumulativeWeight += listSize - index
            self.cumulativeWeightList.append(UInt32(cumulativeWeight))
        }
    }

    func getIndex() -> Int{
        let random = arc4random_uniform(self.cumulativeWeightList.last!)
        var index = -1
        for cumulativeWeight in self.cumulativeWeightList{
            if random < cumulativeWeight {
                index = self.cumulativeWeightList.index(of: cumulativeWeight)!
                break
            }
        }
        return index
    }

    func getIndexList(_ needNum: Int) -> [Int] {
        var indexList: [Int] = []
        let listSize = self.cumulativeWeightList.count
        if  listSize > needNum {
            // 必要な個数が揃うまで繰り返す
            while indexList.count < needNum {
                let index = self.getIndex()
                // 重複した場合スキップする
                if !indexList.contains(index) {
                    indexList.append(index)
                }
            }
        } else {
            for index in 0..<listSize {
                indexList.append(index)
            }
        }
        indexList.sort()
        return indexList
    }
}
