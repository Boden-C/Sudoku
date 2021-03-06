 
//Copyright Boden Font 2021
class CustomDigitFont {
    let array:[[String]]

    init() {
        self.array = [
          [
            "   ",
            "   ",
            "   ",
          ],[
              " ┐ ",
              " │ ",
              " ┴ ",
            ],[
                "╭─╮",
                "╭─╯",
                "└─╴",
              ],[
                  "╶─╮",
                  "╶─┤",
                  "╶─╯",
                ],[
                    "╷ ╷",
                    "└─┤",
                    "  ╵",
                  ],[
                      "┌─╴",
                      "└─╮",
                      "╰─╯",
                    ],[
                        "╭─╮",
                        "├─╮",
                        "╰─╯",
                      ],[
                          "___",
                          "  ╱",
                          " ╱ ",
                        ],[
                            "╭─╮",
                            "├─┤",
                            "╰─╯",
                          ],[
                              "╭─╮",
                              "╰─┤",
                              "  ╵",
                            ]
        ]
    }

    func array(_ index:Int) -> [String] {
        return self.array[index]
    }
}
