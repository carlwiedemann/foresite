# Foresite

Foresite is an extremely minimal static site generator. It is a single executable that converts markdown and a single template to generate a static site.

Foresite is a great choice for simple blogs hosted on [GitHub Pages](https://pages.github.com/) or similar.

## Requirements

* Ruby >= 2.7.0

## Installation

    gem install foresite

## Example: Hello World

    mkdir my_blog 
    cd my_blog
    foresite init
    foresite touch "Hello World"
    foresite build

Quickly view in a browser using Python's `http.server`:

    python -m http.server 8000 --directory out

![Screenshot of Hello World post](screenshot.png)

## Detailed instructions

### 1. Create your project directory

After installing foresite, create a project directory for your site, and run `foresite init`:

    $ mkdir my_blog
    $ cd my_blog
    $ foresite init
    Created directory /Users/carlwiedemann/my_blog/md
    Created directory /Users/carlwiedemann/my_blog/out
    Created file /Users/carlwiedemann/my_blog/template.rhtml

A single template file and two subdirectories are created:

* `md` subdirectory: Will contain markdown files (.md) for you to edit. The markdown files are the *source of truth* for your site's content.
* `out` subdirectory: Will contain HTML files (.md) generated from the markdown and an `index.html` file for your site's home page.
* The `template.rhtml` file is an HTML wrapper template using [Embedded Ruby (ERB)](https://docs.ruby-lang.org/en/3.2/ERB.html) for all generated the HTML files.

### 2. Write your first post

You can create your first post with `foresite touch`, passing a title as its sole argument:

    $ foresite touch "Welcome to my site"
    Created file /Users/carlwiedemann/my_blog/md/2023-01-15-welcome-to-my-site.md
    $ cat md
    # Welcome to my site
    
    2023-01-15

A single markdown file is generated in the `md` subdirectory. **This file is for you to edit.**

* Its title is the first line formatted as a markdown H1.
* Today's date in YYYY-MM-DD format is the first markdown paragraph.
* The date and title are slugified to form the filename. *Please keep the date in the filename, it is used to generate the index page.*

### 3. Craft your HTML wrapper template

The `template.rhtml` file wraps all of your markdown. **This file is for you to edit.**

There is only one template variable, `@content [String]` which holds parsed markdown as its HTML equivalent.

#### 4. Generate HTML from markdown

When you are ready to generate HTML from your markdown files and template file, run `foresite build`:

    $ foresite build
    Created file /Users/carlwiedemann/my_blog/out/2023-01-15-welcome-to-my-site.html
    Created file /Users/carlwiedemann/my_blog/out/index.html

In this example, two HTML files are generated in the `out` directory:

* For every markdown file in the `md` subdirectory an equivalent HTML file is generated in the `out` subdirectory, parsed markdown contents being wrapped with wrapper template.
* A single `index.html` file, which provides `@content` with an `<ul>` holding links to all posts, and their dates.
  * The titles in the list are parsed from the first H1 tag in each markdown file.
  * The dates in the list are parsed from the filename.

In this example, the `index.html` file contains the following:

```html
<ul>
  <li>2023-01-15 <a href="2023-01-15-welcome-to-my-site.html">Welcome to my site</a></li>
</ul>
```

## Use GitHub Pages to host your content

You'll want to use the `out` subdirectory as its publishing source, see [Configuring a publishing source for your GitHub Pages site](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site). 

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install:local`. You will then be able to execute the CLI by running `foresite` in a terminal.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/carlwiedemann/foresite.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
