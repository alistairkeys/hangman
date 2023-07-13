# Package

version       = "0.1.0"
author        = "Ali Keys"
description   = "A simple Hangman game"
license       = "MIT"
srcDir        = "src"
bin           = @["hangman"]


# Dependencies

requires "nim >= 1.6.0",
         "staticglfw >= 4.1.3",
         "boxy >= 0.4.1"