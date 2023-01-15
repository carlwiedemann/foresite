# Foresite - An Extremely Minimal Static Site Generator

CLI executable that converts markdown wrapped in a single template to static HTML for simple blogs hosted on [GitHub Pages](https://pages.github.com/) or similar.

## Installation

The only requirement is Ruby >= 2.7.0.

    $ gem install foresite

## Quick start: Hello World

    $ mkdir my_blog                 # Create a project directory
    $ cd my_blog
    $ foresite init                 # Initialize subdirectories for markdown and HTML
    $ foresite touch "Hello World"  # Create first post as markdown
    $ foresite build                # Converts markdown to HTML

![Screenshot of Hello World post](screenshot.png)

## Getting started guide

### 1. Create your project directory

After installing foresite using `gem install foresite`, create a project directory for your site, and run `foresite init` from within it:

    $ mkdir my_blog
    $ cd my_blog
    $ foresite init
    Created directory /Users/carlwiedemann/my_blog/md
    Created directory /Users/carlwiedemann/my_blog/out
    Created file /Users/carlwiedemann/my_blog/template.rhtml

A single wrapper template file and two subdirectories are created.

Some facts:

* `md` subdirectory contains markdown files for editing. Each markdown file will be a separate post and *source of truth* for your site's content.
* `out` subdirectory contains generated HTML files including an `index.html` file listing all posts.
* `template.rhtml` file is a sole wrapper template using [Embedded Ruby (ERB)](https://docs.ruby-lang.org/en/3.2/ERB.html).

### 2. Write your first post

Run `foresite touch` to generate a new markdown file in the `md` subdirectory. The post title is its sole argument:

    $ foresite touch "Welcome to my site"
    Created file /Users/carlwiedemann/my_blog/md/2023-01-15-welcome-to-my-site.md
    $ cat md
    # Welcome to my site
    
    2023-01-15

A single markdown file is created in the `md` subdirectory. **This file is for you to edit.**

Some facts:

* The title is the first line formatted as H1 (mandatory).
* Current date in YYYY-MM-DD format is the first markdown paragraph (optional).
* Current date and title are "slugified" for filename.

### 3. Modify your wrapper template as desired

The `template.rhtml` file wraps all of your markdown. **This file is for you to edit.**

There is only one template variable, `@content`. For generated posts, `@content` is post markdown converted to HTML. For the `index.html` file, `@content` is a list of links to posts in reverse-chronological order.

### 4. Generate HTML from markdown

Run `foresite build` to create HTML in the `out` subdirectory:

    $ foresite build
    Created file /Users/carlwiedemann/my_blog/out/2023-01-15-welcome-to-my-site.html
    Created file /Users/carlwiedemann/my_blog/out/index.html

In this example, two HTML files are created.

Some facts:

* For every markdown file in the `md` subdirectory an equivalent HTML file is generated in the `out` subdirectory, where the parsed markdown is wrapped with wrapper template markup.
* A single `index.html` file, which provides `@content` with an `<ul>` holding links to all posts, prefixed with post date.
  * Titles are parsed from the first H1 tag in each markdown file.
  * Dates are parsed from the filename.
* Re-running `foresite build` removes all files in the `out` subdirectory.

In this example, the `index.html` will contain:

```html
<ul>
  <li>2023-01-15 <a href="2023-01-15-welcome-to-my-site.html">Welcome to my site</a></li>
</ul>
```

## Use GitHub Pages to host your content

You'll want to use the `out` subdirectory as its publishing source, see [Configuring a publishing source for your GitHub Pages site](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site). 

## Development

1. Clone
2. `bundle` to install dependencies
3. `bundle exec rake` to run tests & linter

To install this gem from local source, run `bundle exec rake install:local`.

## Contributing

Bug reports and pull requests are welcome. The goals of Foresite are:

* Extremely lightweight
* Simple to use & understand
* Light on features

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
