//  LMCrypto
//
//  Created by Sittichai Chumjai on 11/3/2567 BE.
//

import Foundation

struct BaseRespone<T: Codable>: Codable  {
    let status: String
    let data: T?
}

