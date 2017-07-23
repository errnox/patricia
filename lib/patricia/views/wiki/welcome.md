# Welcome

This is *Patricia*, a simple markup-based Wiki. You feed it a directory
full of markup files and it can do two things for you.

1. Serve the files for you dynamically; refreshing the page will always
   fetch the current state of the markup file.
2. Generate an output directory full of static HTML files that you can
   serve yourself.

## Usage

To start serving your files dynamically, run

        patricia /path/to/markup/dir -p 4321

`-p` will use a port of your choice. If you supply `-t`, hovering over
items in the sidebar will show a tooltip with the path to the associated
markup file or directory.

The `--css` and `--js` options allow you to use your own stylesheets and
JavaScipt files.

To see all available options, run `patricia --help`.

---------------------------------------------------------------------------

If you want to generate an output directory full of static HTML files, run

        patricia /path/to/markup/dir /path/to/output/dir

Of course, you can also use `--css` and `--js` here, too. Don't forget to
serve those CSS and JavaScript asset files with the correct path, though
when actually serving the Wiki from your server/CDN.

## Links

Links are relative to the root of your markup directory, but the root
directory name itself can be left out.

Suppose you have a markup directory structure that looks like this:


        .
        my-flower-wiki
        |-- small-flowers
        |   |-- bright-colors
        |   |   |-- orange.md
        |   |   |-- red.markdown
        |   |   `-- yellow.rst
        |   |-- dark-colors
        |   |   |-- blue.md
        |   |   `-- violet.org
        |   `-- overview.pdf
        `-- tall-flowers
            |-- bright-colors
            |   |-- orange.md
            |   |-- red.markdown
            |   `-- yellow.rst
            `-- dark-colors
                |-- blue.md
                `-- violet.org

To link from `my-flower-wiki/small-flowers/brigh-colors/red.md` to
`my-flower-wiki/tall-flowers/dark-colors/blue.md`, you would specify a link
with the **full path**, but **without the markup file extension**:

        [Tall dark blue flower](/tall-flowers/dark-colors/blue)

## Images

Images, like links, use the **full path**, but, unlike links,
**do include the file extension**:

        ![Rose image](tall-flowers/bright-colors/rose.png)

## PDFs/videos/text files/...

Static files work just like images, specifiy the **full path** and
**do include the file extension**:

        [Overview PDF](tall-flowers/overview.pdf)

## Installation

You already have Patricia, but if you want to make a friend a Patricia
user, run:

        gem install patricia

---------------------------------------------------------------------------

## Sidebar

- The search box is case-insensitive, but otherwise RegEx-aware.
- The sidebar can be widened. Click `Widen sidebar` or hit the `w` key.
- Hit `s` to focus the search bar from wherever you are on a page.

## Editor

- Use the `-e` flag to enable the editor.
- There are three ways to edit text:
  1. Hover over elements. Editable elements will present you with an `Edit`
     link.
  2. Hover over an editable element and press the `e` key.
  3. Highlight some arbitrary text and press the `Edit` button that appears
     or hit the `e` key.
- Patricia tries to figure out which markup source matches the selected
  text. If there are multiple matches, you can step through all of them.

## Tooltips

... can be enabled using the `-t` flag and will show tooltips for every
sidebar item.

## Page Search

- There is a `Search pages` link on every page.
- The search is performed across all markup source files and will return a
  list of matching pages.
- Regular expressions can be used.

## GitHub Flavored Markdown

With the `-g` command line switch you can use GitHub Flavored Markdown.
This will force *all* pages to be rendered using the `github-markdown` gem.
Consequence: All the markup languages supported by this gem are supported
by Patircia.

## Keyboard Shortcuts

Press `?` to get a list of all keyboard shortcuts.

---------------------------------------------------------------------------
