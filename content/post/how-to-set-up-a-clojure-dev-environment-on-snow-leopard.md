---
layout: post
title: "How to set up a Clojure dev environment on Snow Leopard"
date: "2013-02-02"
categories:
  - osx
  - clojure
  - development
---

### Homebrew (package manager)

    $ ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"

More information on Homebrew can be found on the [Homebrew home page](http://mxcl.github.com/homebrew/ 'Homebrew home page')

<!--more-->

### Emacs 24 (editor)

    $ brew install emacs --cocoa --use-git-head --HEAD # this takes a while

### Emacs Prelude (enhanced Emacs 24 configuration)

    $ git clone git://github.com/bbatsov/prelude.git /path/to/prelude
    $ ln -s /path/to/prelude ~/.emacs.d

More information on Prelude can be found on the [Prelude home page](http://batsov.com/prelude/ 'Prelude home page').

### ParEdit (emacs minor mode for editing parentheses)

    $ emacs
    M-x package-install [RET] paredit [RET]

Add to ~/.emacs.d/init.el:

    (add-hook 'nrepl-mode-hook 'paredit-mode)

See the EmacsWiki: [ParEdit](http://emacswiki.org/emacs/ParEdit 'ParEdit') and [ParEdit Cheatsheet](http://emacswiki.org/emacs/PareditCheatsheet 'ParEdit Cheatsheet').

### Clojure

    $ git clone https://github.com/clojure/clojure.git /path/to/clojure
    $ cd /path/to/clojure
    $ ./antsetup.sh
    $ ant
    $ mkdir ~/.clojure
    $ ln -s /path/to/clojure/clojure.jar ~/.clojure/clojure.jar

### Leiningen (Clojure automation tool)

    $ wget -O /usr/local/bin/lein https://raw.github.com/technomancy/leiningen/preview/bin/lein
    $ chmod 755 /usr/local/bin/lein

More information on Leiningen can be found on the [Leiningen home page](http://leiningen.org/ 'Leiningen home page').

***

Finally:

    $ emacs
    M-x nrepl-jack-in
