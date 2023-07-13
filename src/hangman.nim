import boxy, opengl, staticglfw
import hangmangame

const
  windowWidth = 800
  windowHeight = 400

var
  game = initGame()

proc handleKeyPress(window: Window, key, scancode, action, modifiers: cint) {.cdecl.} =
  if action == PRESS:
    if game.state != inProgress and key in {KEY_SPACE}:
      echo "Starting new game"
      game = initGame()
    elif key in {KEY_A .. KEY_Z, KEY_ESCAPE}:
      echo "Pressed a key: ", key
      case key
        of KEY_ESCAPE: window.setWindowShouldClose(1.cint)
        of KEY_A..KEY_Z: game.addLetter(chr(key))
        else: discard

proc doGame() =
  let windowSize = ivec2(windowWidth, windowHeight)

  if init() == 0:
    quit("Failed to Initialize GLFW.")

  windowHint(RESIZABLE, false.cint)
  windowHint(CONTEXT_VERSION_MAJOR, 4)
  windowHint(CONTEXT_VERSION_MINOR, 1)

  let window = createWindow(windowSize.x, windowSize.y, "Guess the Word", nil, nil)
  makeContextCurrent(window)

  loadExtensions()

  discard window.setKeyCallback(handleKeyPress)

  var bxy = newBoxy()

  proc generateLetters(bxy: Boxy) =
    var typeface = readTypeface(getDataDir() & "IBMPlexMono-Bold.ttf")
    var font = newFont(typeface)
    font.size = 28
    font.paint = "#000000"
    for ch in {'A'..'Z', 'a'..'z', '0'..'9'} + hangmanPunctuation:
      let arrangement = typeset(@[newSpan($ch, font)], bounds = vec2(32, 32))
      let textImage = newImage(32, 32)
      textImage.fillText(arrangement)
      bxy.addImage("text" & $ch, textImage)

  proc generateHangedMan(bxy: Boxy) =
    let hangmanImage = newImage(128, 160)
    let ctx = hangmanImage.newContext
    ctx.strokeStyle = "#000000"
    ctx.lineWidth = 5

    # wrong guess 1 = frame
    ctx.strokeSegment(segment(vec2(60, 159), vec2(127, 159)))
    ctx.strokeSegment(segment(vec2(120, 159), vec2(120, 10)))
    ctx.strokeSegment(segment(vec2(120, 10), vec2(60, 10)))
    ctx.strokeSegment(segment(vec2(60, 10), vec2(60, 30)))
    bxy.addImage("hangman1", hangmanImage)

    # wrong guess 2 = frame + head
    ctx.strokeCircle(Circle(pos: vec2(60, 46), radius: 16))
    bxy.addImage("hangman2", hangmanImage)

    # wrong guess 3 = frame + head + body
    ctx.strokeSegment(segment(vec2(60, 62), vec2(60, 110)))
    bxy.addImage("hangman3", hangmanImage)

    # wrong guess 4 = frame + head + body + left arm
    ctx.strokeSegment(segment(vec2(60, 77), vec2(35, 90)))
    bxy.addImage("hangman4", hangmanImage)

    # wrong guess 5 = frame + head + body + both arms
    ctx.strokeSegment(segment(vec2(60, 77), vec2(85, 90)))
    bxy.addImage("hangman5", hangmanImage)

    # wrong guess 6 = frame + head + body + both arms + left leg
    ctx.strokeSegment(segment(vec2(60, 110), vec2(35, 140)))
    bxy.addImage("hangman6", hangmanImage)

    # wrong guess 7 = frame + head + body + both arms + both legs
    ctx.strokeSegment(segment(vec2(60, 110), vec2(85, 140)))
    bxy.addImage("hangman7", hangmanImage)

    # wrong guess 8 = RIP face
    ctx.lineWidth = 2
    ctx.strokeSegment(segment(vec2(52, 42), vec2(57, 47)))
    ctx.strokeSegment(segment(vec2(57, 42), vec2(52, 47)))
    ctx.strokeSegment(segment(vec2(63, 42), vec2(68, 47)))
    ctx.strokeSegment(segment(vec2(68, 42), vec2(63, 47)))
    ctx.strokeSegment(segment(vec2(53, 53), vec2(67, 53)))
    bxy.addImage("hangman8", hangmanImage)

  bxy.addImage("bg", readImage(getDataDir() & "bg.png"))
  bxy.generateLetters()
  bxy.generateHangedMan()

  proc drawHangedMan(wrongGuessCount: int) =
    if wrongGuessCount > 0:
      bxy.drawImage("hangman" & $wrongGuessCount, rect = rect(vec2(0, 32), vec2(128, 160)))

  proc drawNormalText(text: string, origin: Vec2) =
    var pos = origin
    for ch in text:
      if ch != ' ':
        bxy.drawImage("text" & $ch, rect = rect(pos, vec2(32, 32)))
      pos.x += 16

  proc display() =
    bxy.beginFrame(windowSize)
    bxy.drawImage("bg", rect = rect(vec2(0, 0), windowSize.vec2))

    const helpTextLeft = 250

    drawHangedman(game.wrongGuessCount)

    var y = 24'f32
    case game.state
      of inProgress:
        drawNormalText("Guess the word", vec2(helpTextLeft, y)); y += 24

        block wrongGuesses:
          var left = helpTextLeft + 300'f32
          drawNormalText("Wrong guesses", vec2(left, 24'f32)); y += 24
          if game.wrongGuesses.len == 0:
            drawNormalText("None", vec2(left, y))
          else:
            for idx, ch in game.wrongGuesses:
              drawNormalText($ch, vec2(left, y))
              left += 32

        drawNormalText("Type a letter", vec2(helpTextLeft, y)); y += 128
      of won:
        drawNormalText("Congratulations! You win", vec2(helpTextLeft, y)); y += 64
        drawNormalText("Press Space to play again", vec2(helpTextLeft, y));
      of lost:
        drawNormalText("Sorry, you took too many guesses", vec2(helpTextLeft, y)); y += 64
        drawNormalText("Press Space to play again", vec2(helpTextLeft, y))

    drawNormalText(game.wordWithPlaceholders, vec2(32, 220))

    bxy.endFrame()
    window.swapBuffers()

  while windowShouldClose(window) != 1:
    display()
    waitEvents()

when isMainModule:
  doGame()
