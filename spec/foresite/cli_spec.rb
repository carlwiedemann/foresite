require "tmpdir"
require "pathname"

RSpec.describe Foresite::Cli do
  describe "init" do
    it "returns error for nonexistent directory and exit 1" do
      ENV["FORESITE_ROOT"] = "foo"

      expected_stderr = ForesiteRSpec.cli_line("Nonexistent directory foo")
      expected_exit_code = 1

      expect { Foresite::Cli.new.invoke(:init) }.to output(expected_stderr).to_stderr \
        .and(raise_error(SystemExit) { |error| expect(error.status).to eq(expected_exit_code) })
    end

    it "returns error for non-writable directory and exit 1" do
      ENV["FORESITE_ROOT"] = "/usr"

      expected_stderr = ForesiteRSpec.cli_line("Cannot write to directory /usr")
      expected_exit_code = 1

      expect { Foresite::Cli.new.invoke(:init) }.to output(expected_stderr).to_stderr \
        .and(raise_error(SystemExit) { |error| expect(error.status).to eq(expected_exit_code) })
    end

    it "creates the subdirectories and copies the sample template" do
      Dir.mktmpdir do |tmpdir|
        ENV["FORESITE_ROOT"] = tmpdir

        expected_stdout = ForesiteRSpec.cli_lines([
          "Created md/",
          "Created post/",
          "Created erb/",
          "Created erb/post.md.erb",
          "Created erb/wrapper.html.erb",
          "Created erb/_list.html.erb"
        ])

        expect { Foresite::Cli.new.invoke(:init) }.to output(expected_stdout).to_stdout

        expect(Pathname.new("#{tmpdir}/md")).to be_directory
        expect(Pathname.new("#{tmpdir}/post")).to be_directory
        expect(Pathname.new("#{tmpdir}/erb")).to be_directory
        expect(Pathname.new("#{tmpdir}/erb/post.md.erb")).to be_file
        expect(Pathname.new("#{tmpdir}/erb/wrapper.html.erb")).to be_file
        expect(Pathname.new("#{tmpdir}/erb/_list.html.erb")).to be_file

        expect(Dir.new("#{tmpdir}/md").children).to eq([])
        expect(Dir.new("#{tmpdir}/post").children).to eq([])
      end
    end

    it "does not overwrite existing files" do
      Dir.mktmpdir do |tmpdir|
        ENV["FORESITE_ROOT"] = tmpdir

        expected_stdout = ForesiteRSpec.cli_lines([
          "md/ already exists",
          "post/ already exists",
          "erb/ already exists",
          "erb/post.md.erb already exists",
          "erb/wrapper.html.erb already exists",
          "erb/_list.html.erb already exists"
        ])

        # Invoke first time.
        Foresite::Cli.new.invoke(:init)

        # Invoke second time.
        expect { Foresite::Cli.new.invoke(:init) }.to output(expected_stdout).to_stdout
      end
    end
  end

  describe "touch" do
    it "returns error if initialization has not happened" do
      Dir.mktmpdir do |tmpdir|
        ENV["FORESITE_ROOT"] = tmpdir

        exptected_stderr = ForesiteRSpec.cli_line("Missing subdirectories, try running `foresite init`")
        expected_exit_code = 1

        expect { Foresite::Cli.new.invoke(:touch, ["something"]) }.to output(exptected_stderr).to_stderr \
          .and(raise_error(SystemExit) { |error| expect(error.status).to eq(expected_exit_code) })
      end
    end

    it "generates a blank markdown file, with title" do
      Dir.mktmpdir do |tmpdir|
        ENV["FORESITE_ROOT"] = tmpdir

        # Initialize before touching.
        Foresite::Cli.new.invoke(:init)

        ymd = Time.now.strftime("%F")

        expected_path = "#{tmpdir}/md/#{ymd}-jackdaws-love-my-big-sphinx-of-quartz.md"
        expected_stdout = ForesiteRSpec.cli_line("Created md/#{ymd}-jackdaws-love-my-big-sphinx-of-quartz.md")
        expected_file_content = <<~EOF
          # Jackdaws Love my Big Sphinx of Quartz!

          #{ymd}

        EOF

        touch_args = ["Jackdaws Love my Big Sphinx of Quartz!"]

        expect { Foresite::Cli.new.invoke(:touch, touch_args) }.to output(expected_stdout).to_stdout
        expect(Pathname.new(expected_path)).to be_file
        expect(File.read(expected_path)).to eq(expected_file_content)
      end
    end

    it "does not duplicate an existing markdown file" do
      Dir.mktmpdir do |tmpdir|
        ENV["FORESITE_ROOT"] = tmpdir

        # Initialize before touching.
        Foresite::Cli.new.invoke(:init)

        ymd = Time.now.strftime("%F")

        touch_args = ["Jackdaws Love my Big Sphinx of Quartz!"]

        # First touch.
        Foresite::Cli.new.invoke(:touch, touch_args)
        # Mutate file to confirm contents don't change.
        expected_path = "#{tmpdir}/md/#{ymd}-jackdaws-love-my-big-sphinx-of-quartz.md"
        existing_file_content = <<~EOF
          # Jackdaws Love my Big Sphinx of Quartz!

          #{ymd}

          Hear ye, hear ye.

        EOF
        File.write(expected_path, existing_file_content)

        # Second touch.
        expected_stdout = ForesiteRSpec.cli_line("File md/#{ymd}-jackdaws-love-my-big-sphinx-of-quartz.md already exists")
        expect { Foresite::Cli.new.invoke(:touch, touch_args) }.to output(expected_stdout).to_stdout
        expect(File.read(expected_path)).to eq(existing_file_content)
      end
    end
  end

  describe "build" do
    it "generates HTML files from markdown files" do
      Dir.mktmpdir do |tmpdir|
        ENV["FORESITE_ROOT"] = tmpdir

        # Initialize and touch two files.
        Foresite::Cli.new.invoke(:init)
        Foresite::Cli.new.invoke(:touch, ["Jackdaws Love my Big Sphinx of Quartz!"])
        Foresite::Cli.new.invoke(:touch, ["When Zombies Arrive, Quickly Fax Judge Pat"])

        ymd = Time.now.strftime("%F")

        path_to_first = "#{tmpdir}/md/#{ymd}-jackdaws-love-my-big-sphinx-of-quartz.md"
        # Simulate the first file being written previously.
        File.write(path_to_first.gsub(/\d{4}-\d{2}-\d{2}/, "2022-12-25"), File.read(path_to_first))
        File.delete(path_to_first)

        expected_path_first = "#{tmpdir}/post/2022-12-25-jackdaws-love-my-big-sphinx-of-quartz.html"
        expected_path_second = "#{tmpdir}/post/#{ymd}-when-zombies-arrive-quickly-fax-judge-pat.html"
        expected_path_index = "#{tmpdir}/index.html"

        expected_stdout = ForesiteRSpec.cli_lines([
          "Created post/2022-12-25-jackdaws-love-my-big-sphinx-of-quartz.html",
          "Created post/#{ymd}-when-zombies-arrive-quickly-fax-judge-pat.html",
          "Created index.html"
        ])

        # Run build
        expect { Foresite::Cli.new.invoke(:build) }.to output(expected_stdout).to_stdout
        # HTML files should exist.
        expect(Pathname.new(expected_path_first)).to be_file
        expect(Pathname.new(expected_path_second)).to be_file

        expected_content_first = <<~EOF
          <h1 id="jackdaws-love-my-big-sphinx-of-quartz">Jackdaws Love my Big Sphinx of Quartz!</h1>

          <p>#{ymd}</p>

        EOF

        expected_content_second = <<~EOF
          <h1 id="when-zombies-arrive-quickly-fax-judge-pat">When Zombies Arrive, Quickly Fax Judge Pat</h1>

          <p>#{ymd}</p>

        EOF

        expected_content_index = <<~EOF
          <ul>
            <li>#{ymd} <a href="post/#{ymd}-when-zombies-arrive-quickly-fax-judge-pat.html">When Zombies Arrive, Quickly Fax Judge Pat</a></li>
            <li>2022-12-25 <a href="post/2022-12-25-jackdaws-love-my-big-sphinx-of-quartz.html">Jackdaws Love my Big Sphinx of Quartz!</a></li>
          </ul>
        EOF

        # HTML file contents should contain generated markdown.
        expect(File.read(expected_path_first)).to include(expected_content_first)
        expect(File.read(expected_path_second)).to include(expected_content_second)
        expect(File.read(expected_path_index)).to include(expected_content_index)

        # They should also use the top-level HTML template, we can just use a dummy string to confirm.
        expected_title_index = "<title>Another Foresite Blog</title>"
        expected_title_first = "<title>Jackdaws Love my Big Sphinx of Quartz! - Another Foresite Blog</title>"
        expected_title_second = "<title>When Zombies Arrive, Quickly Fax Judge Pat - Another Foresite Blog</title>"
        expect(File.read(expected_path_first)).to include(expected_title_first)
        expect(File.read(expected_path_second)).to include(expected_title_second)
        expect(File.read(expected_path_index)).to include(expected_title_index)
      end
    end

    it "returns error if initialization has not happened" do
      Dir.mktmpdir do |tmpdir|
        ENV["FORESITE_ROOT"] = tmpdir

        exptected_stderr = ForesiteRSpec.cli_line("Missing subdirectories, try running `foresite init`")
        expected_exit_code = 1

        expect { Foresite::Cli.new.invoke(:build) }.to output(exptected_stderr).to_stderr \
          .and(raise_error(SystemExit) { |error| expect(error.status).to eq(expected_exit_code) })
      end
    end

    it "returns error if no markdown files are available" do
      Dir.mktmpdir do |tmpdir|
        ENV["FORESITE_ROOT"] = tmpdir

        # Initialize, but don't touch any files.
        Foresite::Cli.new.invoke(:init)

        exptected_stderr = ForesiteRSpec.cli_line("No markdown files, try running `foresite touch`")
        expected_exit_code = 1

        expect { Foresite::Cli.new.invoke(:build) }.to output(exptected_stderr).to_stderr \
          .and(raise_error(SystemExit) { |error| expect(error.status).to eq(expected_exit_code) })
      end
    end
  end
end
