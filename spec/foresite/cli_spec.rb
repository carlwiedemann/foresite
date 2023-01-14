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
          "Created directory #{tmpdir}/md",
          "Created directory #{tmpdir}/out",
          "Created file #{tmpdir}/template.rhtml"
        ])

        expect { Foresite::Cli.new.invoke(:init) }.to output(expected_stdout).to_stdout

        expect(Pathname.new("#{tmpdir}/md")).to be_directory
        expect(Pathname.new("#{tmpdir}/out")).to be_directory
        expect(Pathname.new("#{tmpdir}/template.rhtml")).to be_file

        expect(Dir.new("#{tmpdir}/md").children).to eq([])
        expect(Dir.new("#{tmpdir}/out").children).to eq([])
      end
    end

    it "does not overwrite existing files" do
      Dir.mktmpdir do |tmpdir|
        ENV["FORESITE_ROOT"] = tmpdir

        expected_stdout = ForesiteRSpec.cli_lines([
          "Directory #{tmpdir}/md already exists",
          "Directory #{tmpdir}/out already exists",
          "File #{tmpdir}/template.rhtml already exists"
        ])

        # Invoke first time.
        Foresite::Cli.new.invoke(:init)

        # Invoke second time.
        expect { Foresite::Cli.new.invoke(:init) }.to output(expected_stdout).to_stdout
      end
    end
  end

  describe "touch" do
    it "shows error if initialization has not happened" do
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

        time_now = Time.now

        expected_path_to_file = "#{tmpdir}/md/#{time_now.strftime("%Y%m%d")}-jackdaws-love-my-big-sphinx-of-quartz.md"
        expected_stdout = ForesiteRSpec.cli_line("Created file #{expected_path_to_file}")
        expected_file_content = <<~EOF
          # Jackdaws Love my Big Sphinx of Quartz

          #{time_now.strftime("%F")}

        EOF

        touch_args = ["Jackdaws Love my Big Sphinx of Quartz"]

        expect { Foresite::Cli.new.invoke(:touch, touch_args) }.to output(expected_stdout).to_stdout
        expect(Pathname.new(expected_path_to_file)).to be_file
        expect(File.read(expected_path_to_file)).to eq(expected_file_content)
      end
    end

    it "does not duplicate an existing markdown file" do
      Dir.mktmpdir do |tmpdir|
        ENV["FORESITE_ROOT"] = tmpdir

        # Initialize before touching.
        Foresite::Cli.new.invoke(:init)

        time_now = Time.now

        touch_args = ["Jackdaws Love my Big Sphinx of Quartz"]

        # First touch.
        Foresite::Cli.new.invoke(:touch, touch_args)
        # Mutate file to confirm contents don't change.
        expected_path_to_file = "#{tmpdir}/md/#{time_now.strftime("%Y%m%d")}-jackdaws-love-my-big-sphinx-of-quartz.md"
        existing_file_content = <<~EOF
          # Jackdaws Love my Big Sphinx of Quartz

          #{time_now.strftime("%F")}

          Hear ye, hear ye.

        EOF
        File.write(expected_path_to_file, existing_file_content)

        # Second touch.
        expected_stdout = ForesiteRSpec.cli_line("File #{expected_path_to_file} already exists")
        expect { Foresite::Cli.new.invoke(:touch, touch_args) }.to output(expected_stdout).to_stdout
        expect(File.read(expected_path_to_file)).to eq(existing_file_content)
      end
    end
  end

  describe "build" do
    it "generates HTML files from markdown files" do
      Dir.mktmpdir do |tmpdir|
        ENV["FORESITE_ROOT"] = tmpdir

        # Initialize and touch two files.
        Foresite::Cli.new.invoke(:init)
        Foresite::Cli.new.invoke(:touch, ["Jackdaws Love my Big Sphinx of Quartz"])
        Foresite::Cli.new.invoke(:touch, ["When Zombies Arrive, Quickly Fax Judge Pat"])

        time_now = Time.now
        yyyymmdd = time_now.strftime("%Y%m%d")
        yyyy_mm_dd = time_now.strftime("%F")

        expected_path_to_first_file = "#{tmpdir}/out/#{yyyymmdd}-jackdaws-love-my-big-sphinx-of-quartz.html"
        expected_path_to_second_file = "#{tmpdir}/out/#{yyyymmdd}-when-zombies-arrive-quickly-fax-judge-pat.html"
        expected_path_to_index_file = "#{tmpdir}/out/index.html"

        expected_stdout = ForesiteRSpec.cli_lines([
          "Created file #{expected_path_to_first_file}",
          "Created file #{expected_path_to_second_file}",
          "Created file #{expected_path_to_index_file}"
        ])

        # Run build
        expect { Foresite::Cli.new.invoke(:build) }.to output(expected_stdout).to_stdout
        # HTML files should exist.
        expect(Pathname.new(expected_path_to_first_file)).to be_file
        expect(Pathname.new(expected_path_to_second_file)).to be_file

        expected_first_file_content = <<~EOF
          <h1 id="jackdaws-love-my-big-sphinx-of-quartz">Jackdaws Love my Big Sphinx of Quartz</h1>

          <p>#{yyyy_mm_dd}</p>

        EOF

        expected_second_file_content = <<~EOF
          <h1 id="when-zombies-arrive-quickly-fax-judge-pat">When Zombies Arrive, Quickly Fax Judge Pat</h1>

          <p>#{yyyy_mm_dd}</p>

        EOF

        expected_index_file_content = <<~EOF
          <ul>
            <li>#{yyyy_mm_dd} <a href="#{yyyymmdd}-jackdaws-love-my-big-sphinx-of-quartz.html">Jackdaws Love my Big Sphinx of Quartz</a></li>
            <li>#{yyyy_mm_dd} <a href="#{yyyymmdd}-when-zombies-arrive-quickly-fax-judge-pat.html">When Zombies Arrive, Quickly Fax Judge Pat</a></li>
          </ul>
        EOF

        # HTML file contents should contain generated markdown.
        expect(File.read(expected_path_to_first_file)).to include(expected_first_file_content)
        expect(File.read(expected_path_to_second_file)).to include(expected_second_file_content)
        expect(File.read(expected_path_to_index_file)).to include(expected_index_file_content)

        # They should also use the top-level HTML template, we can just use a dummy string to confirm.
        expected_template_content = "<title>Another foresite website</title>"
        expect(File.read(expected_path_to_first_file)).to include(expected_template_content)
        expect(File.read(expected_path_to_second_file)).to include(expected_template_content)
        expect(File.read(expected_path_to_index_file)).to include(expected_template_content)
      end
    end

    it "shows error if initialization has not happened"

    it "shows error if no markdown files are available"
  end
end
