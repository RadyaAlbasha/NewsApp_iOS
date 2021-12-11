//
//  ErrorMessage.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import Foundation
enum ErrorMessage: String, Error{
    case SERVER_MESSAGE = "Server is down"
    case NO_CONNECTION = "The Internet connection appears to be offline"
    case NO_DATA = "No Data available"
    case INVALID_CONFIGRATION = "invalid configration"
}
