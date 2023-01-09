require 'erb'

require 'bundler/setup'

require 'kramdown'
require 'ruby-progressbar'
require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir('lib')
loader.setup

DIR_MARKDOWN = 'md'
DIR_HTML = 'out'

namespace :foresite do

  desc 'Generate blank markdown file'
  task :touch do
    time_now = Time.now

    base_filename = time_now.strftime('%Y%m%d')
    base_title = 'Title'

    potential_name = "#{DIR_MARKDOWN}/#{base_filename}-#{base_title.downcase}.md"

    if File.exist?(potential_name)
      $stderr.puts("ERROR - File exists: #{potential_name}")
      abort
    else
      File.write(potential_name, "# #{base_title}\n\n#{time_now.strftime('%F')}\n\n")
    end
  end

  desc 'Generate HTML files from markdown'
  task :build do
    # Wipe all HTML files.
    Dir.glob("#{DIR_HTML}/*").each do |target_file|
      File.delete(target_file)
    end

    markdown_enum = Dir.glob("#{DIR_MARKDOWN}/*.md")

    total_md_files = markdown_enum.count

    total_files = total_md_files + 1

    pb = ProgressBar.create(
      total: total_files,
      format: '%a %b %c/%C'
    )

    if total_md_files > 0
      links = []
      markdown_enum.each do |path_to_markdown|
        pb.increment

        markdown_content = File.read(path_to_markdown)

        content = Kramdown::Document.new(markdown_content).to_html
        filename_markdown = File.basename(path_to_markdown)
        path_to_html = "#{DIR_HTML}/#{filename_markdown.gsub(/\.md$/, '.html')}"

        File.write(path_to_html, Foresite::Renderer.render('rhtml/template.rhtml', {
          content: content
        }))

        title = markdown_content.split("\n").first { |line| /^# [a-z]/i =~ line }.gsub(/^#/, '').strip

        iso_no_space = filename_markdown.split('-').first
        iso_spaces = "#{iso_no_space[0..3]}-#{iso_no_space[4..5]}-#{iso_no_space[6..7]}"

        links.push({
          href: File.basename(path_to_html),
          title: title,
          date: iso_spaces
        })
      end

      inner_nav = links.map do |link|
        "<li>#{link[:date]} <a href=\"#{link[:href]}\">#{link[:title]}</a></li>"
      end

      index_content = "<ul>\n#{inner_nav.join("\n")}</ul>\n"
    else
      index_content = ''
    end

    pb.increment
    # Generate index file.
    File.write("#{DIR_HTML}/index.html", Foresite::Renderer.render('rhtml/template.rhtml', {
      content: index_content
    }))

    puts 'Done!'
  end
end
