//
//  ReminderViewCellDelegate.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 30.11.2025.
//

protocol ReminderViewCellDelegate: AnyObject {
    func reminderCell(_ cell: ReminderViewCell, didChangeDone isDone: Bool)
    func reminderCellDidRequestRemoval(_ cell: ReminderViewCell)
}

