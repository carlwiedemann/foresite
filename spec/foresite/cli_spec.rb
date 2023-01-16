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
          "Created out/",
          "Created erb/",
          "Created erb/post.md.erb",
          "Created erb/wrapper.html.erb",
          "Created erb/_list.html.erb"
        ])

        expect { Foresite::Cli.new.invoke(:init) }.to output(expected_stdout).to_stdout

        expect(Pathname.new("#{tmpdir}/md")).to be_directory
        expect(Pathname.new("#{tmpdir}/out")).to be_directory
        expect(Pathname.new("#{tmpdir}/erb")).to be_directory
        expect(Pathname.new("#{tmpdir}/erb/post.md.erb")).to be_file
        expect(Pathname.new("#{tmpdir}/erb/wrapper.html.erb")).to be_file
        expect(Pathname.new("#{tmpdir}/erb/_list.html.erb")).to be_file

        expect(Dir.new("#{tmpdir}/md").children).to eq([])
        expect(Dir.new("#{tmpdir}/out").children).to eq([])
      end
    end

    it "does not overwrite existing files" do
      Dir.mktmpdir do |tmpdir|
        ENV["FORESITE_ROOT"] = tmpdir

        expected_stdout = ForesiteRSpec.cli_lines([
          "md/ already exists",
          "out/ already exists",
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

        exptected_stderr = ForesiteRSpec.cli_line("No `md` directory, did you run `foresite init` yet?")
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

        expected_full_path_to_file = "#{tmpdir}/md/#{ymd}-jackdaws-love-my-big-sphinx-of-quartz.md"
        expected_relative_path_to_file = "md/#{ymd}-jackdaws-love-my-big-sphinx-of-quartz.md"
        expected_stdout = ForesiteRSpec.cli_line("Created #{expected_relative_path_to_file}")
        expected_file_content = <<~EOF
          # Jackdaws Love my Big Sphinx of Quartz!

          #{ymd}

        EOF

        touch_args = ["Jackdaws Love my Big Sphinx of Quartz!"]

        expect { Foresite::Cli.new.invoke(:touch, touch_args) }.to output(expected_stdout).to_stdout
        expect(Pathname.new(expected_full_path_to_file)).to be_file
        expect(File.read(expected_full_path_to_file)).to eq(expected_file_content)
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
        expected_full_path_to_file = "#{tmpdir}/md/#{ymd}-jackdaws-love-my-big-sphinx-of-quartz.md"
        expected_relative_path_to_file = "md/#{ymd}-jackdaws-love-my-big-sphinx-of-quartz.md"
        existing_file_content = <<~EOF
          # Jackdaws Love my Big Sphinx of Quartz!

          #{ymd}

          Hear ye, hear ye.

        EOF
        File.write(expected_full_path_to_file, existing_file_content)

        # Second touch.
        expected_stdout = ForesiteRSpec.cli_line("File #{expected_relative_path_to_file} already exists")
        expect { Foresite::Cli.new.invoke(:touch, touch_args) }.to output(expected_stdout).to_stdout
        expect(File.read(expected_full_path_to_file)).to eq(existing_file_content)
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

        full_path_to_first_markdown_file = "#{tmpdir}/md/#{ymd}-jackdaws-love-my-big-sphinx-of-quartz.md"
        # Simulate the first file being written previously.
        mutated_full_path_to_first_file = full_path_to_first_markdown_file.gsub(/\d{4}-\d{2}-\d{2}/, "2022-12-25")
        File.write(mutated_full_path_to_first_file, File.read(full_path_to_first_markdown_file))
        File.delete(full_path_to_first_markdown_file)
        expected_full_path_to_first_file = "#{tmpdir}/out/2022-12-25-jackdaws-love-my-big-sphinx-of-quartz.html"
        expected_relative_path_to_first_file = "out/2022-12-25-jackdaws-love-my-big-sphinx-of-quartz.html"

        expected_full_path_to_second_file = "#{tmpdir}/out/#{ymd}-when-zombies-arrive-quickly-fax-judge-pat.html"
        expected_relative_path_to_second_file = "out/#{ymd}-when-zombies-arrive-quickly-fax-judge-pat.html"
        expected_full_path_to_index_file = "#{tmpdir}/out/index.html"
        expected_relative_path_to_index_file = "out/index.html"

        expected_stdout = ForesiteRSpec.cli_lines([
          "Created #{expected_relative_path_to_first_file}",
          "Created #{expected_relative_path_to_second_file}",
          "Created #{expected_relative_path_to_index_file}"
        ])

        # Run build
        expect { Foresite::Cli.new.invoke(:build) }.to output(expected_stdout).to_stdout
        # HTML files should exist.
        expect(Pathname.new(expected_full_path_to_first_file)).to be_file
        expect(Pathname.new(expected_full_path_to_second_file)).to be_file

        expected_first_file_content = <<~EOF
          <h1 id="jackdaws-love-my-big-sphinx-of-quartz">Jackdaws Love my Big Sphinx of Quartz!</h1>

          <p>#{ymd}</p>

        EOF

        expected_second_file_content = <<~EOF
          <h1 id="when-zombies-arrive-quickly-fax-judge-pat">When Zombies Arrive, Quickly Fax Judge Pat</h1>

          <p>#{ymd}</p>

        EOF

        expected_index_file_content = <<~EOF
          <ul>
            <li>#{ymd} <a href="#{ymd}-when-zombies-arrive-quickly-fax-judge-pat.html">When Zombies Arrive, Quickly Fax Judge Pat</a></li>
            <li>2022-12-25 <a href="2022-12-25-jackdaws-love-my-big-sphinx-of-quartz.html">Jackdaws Love my Big Sphinx of Quartz!</a></li>
          </ul>
        EOF

        # HTML file contents should contain generated markdown.
        expect(File.read(expected_full_path_to_first_file)).to include(expected_first_file_content)
        expect(File.read(expected_full_path_to_second_file)).to include(expected_second_file_content)
        expect(File.read(expected_full_path_to_index_file)).to include(expected_index_file_content)

        # They should also use the top-level HTML template, we can just use a dummy string to confirm.
        expected_template_content = "<title>Another Foresite Blog</title>"
        expect(File.read(expected_full_path_to_first_file)).to include(expected_template_content)
        expect(File.read(expected_full_path_to_second_file)).to include(expected_template_content)
        expect(File.read(expected_full_path_to_index_file)).to include(expected_template_content)
      end
    end

    it "returns error if initialization has not happened" do
      Dir.mktmpdir do |tmpdir|
        ENV["FORESITE_ROOT"] = tmpdir

        exptected_stderr = ForesiteRSpec.cli_line("No `md` directory or `out` directory, did you run `foresite init` yet?")
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

        exptected_stderr = ForesiteRSpec.cli_line("No `.md` files, try running `foresite touch`")
        expected_exit_code = 1

        expect { Foresite::Cli.new.invoke(:build) }.to output(exptected_stderr).to_stderr \
          .and(raise_error(SystemExit) { |error| expect(error.status).to eq(expected_exit_code) })
      end
    end
  end
end
