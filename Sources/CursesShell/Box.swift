
import Foundation
import Curses

class Box {
    var box:[[Cell]]

    init(grid:[[Cell]]) {
        self.box = grid
    }

    //currently has no use, most Box components has been integrated into Board and Cell for ease of access and simplicity. Cell has .boxRowNum and .boxColNum for reference.
}
