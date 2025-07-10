//
//  Item.swift
//  TodoMemoApp
//
//  Created by 村崎聖仁 on 2025/07/05.
//

import Foundation
import SwiftData

@Model
final class Item {
    var task: String // タスクの内容
    var isCompleted: Bool // 完了したかどうか
    var timestamp: Date // 作成日
    var memo: String // メモ
    
    init(task: String, isCompleted: Bool = false, timestamp: Date = .now, memo: String = "") {
        self.task = task
        self.isCompleted = isCompleted
        self.timestamp = timestamp
        self.memo = memo
    }
}
