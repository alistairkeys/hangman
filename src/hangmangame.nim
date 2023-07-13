import std/[strutils, sequtils, algorithm, parsecfg, os]

const
  maxGuesses = 8
  hangmanPunctuation* = {'!', ',', '\'', '-', '_', '='};

type
  GameState* = enum
    inProgress, won, lost

  HangmanGame* = object
    state*: GameState
    guessedCorrectly: set[char]
    guessedIncorrectly: set[char]
    word*: string
    wordSet: set[char]

proc getDataDir*(): string =
  if dirExists("./data"): "data/" else: "src/data/"

proc loadNextPhrase(): string =
  result = "Hello world"
  let dataDir = getDataDir()
  echo "DATA DIR: ", dataDir
  try:
    var cfg = loadConfig(dataDir & "config.ini")
    var nextPhraseIdx = cfg.getSectionValue("game", "nextphrase", "0").parseInt
    let phrases = readFile(dataDir & "phrases.txt").splitLines.filterIt(it.strip.len > 0)

    if nextPhraseIdx notin 0 ..< phrases.len:
      nextPhraseIdx = 0

    if phrases.len > 0:
      result = phrases[nextPhraseIdx]
      inc nextPhraseIdx

    cfg.setSectionKey("game", "nextphrase", $nextPhraseIdx)
    cfg.writeConfig(dataDir & "config.ini")
  except CatchableError:
    echo "Error loading a new phrase: ", getCurrentExceptionMsg()

  echo "DEBUG: phrase to guess is " & result

proc initGame*(): HangmanGame =
  let word = loadNextPhrase()
  var wordSet: set[char]
  for ch in word.toUpperAscii:
    if ch in 'A'..'Z': wordSet.incl ch

  result = HangmanGame(
    state: inProgress,
    guessedCorrectly: hangmanPunctuation,
    guessedIncorrectly: {},
    word: word,
    wordSet: wordSet
  )

proc addLetter*(game: var HangmanGame, letter: char) =

  if game.state != inProgress:
    return

  let letter = letter.toUpperAscii

  echo "add letter: " & letter

  if letter in game.guessedCorrectly + game.guessedIncorrectly:
    # Already guessed that letter, ignore it again
    echo "ignoring, already guessed"
    discard
  elif letter in game.wordSet:
    echo "is in word set"
    game.guessedCorrectly.incl letter
    game.wordSet.excl letter
    if game.wordSet == {}:
      game.state = won
  else:
    echo "not in word set"
    game.guessedIncorrectly.incl letter
    if game.guessedIncorrectly.card == maxGuesses:
      game.state = lost

proc wrongGuesses*(game: HangmanGame): string =
  game.guessedIncorrectly.toSeq.sorted.join

proc wrongGuessCount*(game: HangmanGame): int =
  game.guessedIncorrectly.card

proc wordWithPlaceholders*(game: HangmanGame): string =
  result.setLen game.word.len
  for idx, ch in game.word:
    if game.state == lost or ch.toUpperAscii in game.guessedCorrectly + {' '}:
      result[idx] = ch
    else:
      result[idx] = '_'
