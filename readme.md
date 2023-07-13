# Hangman

## What is this?
This is the game Hangman, where you have a fixed number of attempts to guess the
word or phrase. This game is written in [Nim](https://nim-lang.org).

## How do I compile it?
Make sure Nim (1.6.x or higher) is downloaded and installed as per the Nim
website's instructions, including a C compiler like MinGW (GCC).  You can check
both at the command line using:

    nim -v
    gcc -v

This should display the versions of each if they're installed and available on
the path.

You can compile this game using Nimble, the package manager that comes with Nim.
In the root directory (where the hangman.nimble file is):

    nimble build -d:release

... which will install the dependencies and compile the source.  If you've
already installed the dependencies, you can run the Nim compiler directly:

    cd src
    nim c -r hangman

For a smaller executable, you can add the 'strip' flag, although that takes a
little longer (and also consider uncommenting the passL/passC stuff in the
hangman.nim.cfg file, or pass the -d:lto flag to the command line):

    cd src
    nim c -d:strip -r hangman

## How do I play it?
Wikihow has an article on
[Hangman's rules](https://www.wikihow.com/Play-Hangman).

A word or phrase is picked and you have to guess the letters.  Each unguessed
letter is displayed with a '_'.  You get up to eight guesses. Each letter you
guess correctly will be displayed while each wrong guess will move you closer
to being hanged (i.e. closer to losing the game).

If you want to see debug output (i.e. echo statements), remove the '--app:gui'
line in hangman.nim.cfg.  This has the side effect of opening a terminal window
when the app runs when you run it outside an IDE though.

## Any other notes?
The phrases were taken from a random website:
https://onlineteachersuk.com/english-idioms/#part2

They're English idioms so you might not have heard some of them; you can add
your own phrases/words/whatever to the 'phrases.txt' file (I recommend
shuffling the lines in the file before you save it as the game will just go
sequentially through the file each game).

Note that the font generation in _hangman.nim_ (generateLetters) won't contain
all punctuation so if it complains at a missing character, you need to add it to
the list of characters it generates (it's obvious where that happens).

This game uses Treeform's great libraries.  I definitely recommend checking his
GitHub repositories because he has libraries for everything:

https://github.com/treeform

Also an honorary mention to Guzba, his comrade in arms:
https://github.com/guzba

As to why I wrote this game, I simply wanted to get back into programming for
fun outside of work.  I've reached the "I know how to x" stage and don't
actually _do X_, which is a counterproductive mindset.  As a result, I'm trying
to put out knock out as many simple games as I can to get into the habit. These
will include simple things like this as well as more interesting stuff like
Minesweeper and Solitaire.

## Stuff to fix
The text display cuts off letters that go below the baseline like 'g'. I've not
bothered to figure out the exact incantation to get Pixie to generate text
within the correct bounds.