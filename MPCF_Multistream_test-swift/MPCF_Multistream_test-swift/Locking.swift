//
// Created by Alexander Evsyuchenya on 7/27/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation

func sync<T>(lock: AnyObject, @noescape closure: () -> T) -> T {
    objc_sync_enter(lock)
    let res = closure()
    objc_sync_exit(lock)
    return res
}