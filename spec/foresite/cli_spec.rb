require "tmpdir"
require "pathname"

RSpec.describe Foresite::Cli do
  describe "init" do
    it "should display error for nonexistent directory and exit 1" do
      ENV['FORESITE_ROOT'] = 'foo'

      expected_stderr = ForesiteRSpec.cli_line("Nonexistent directory foo")
      expected_exit_code = 1

      expect { Foresite::Cli.new.invoke(:init) }.to output(expected_stderr).to_stderr \
        .and(raise_error(SystemExit) { |error| expect(error.status).to eq(expected_exit_code) })
    end

    it "should display error for non-writable directory and exit 1" do
      ENV['FORESITE_ROOT'] = '/usr'

      expected_stderr = ForesiteRSpec.cli_line("Cannot write to directory /usr")
      expected_exit_code = 1

      expect { Foresite::Cli.new.invoke(:init) }.to output(expected_stderr).to_stderr \
        .and(raise_error(SystemExit) { |error| expect(error.status).to eq(expected_exit_code) })
    end

    it "should create the md directory and copy the sample template" do
      Dir.mktmpdir do |tmpdir|
        ENV['FORESITE_ROOT'] = tmpdir

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

    it "should not overwrite existing files" do
      Dir.mktmpdir do |tmpdir|
        ENV['FORESITE_ROOT'] = tmpdir

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
    it "should generate a blank markdown file, with title" do
      Dir.mktmpdir do |tmpdir|
        ENV['FORESITE_ROOT'] = tmpdir

        # Initialize before touching.
        Foresite::Cli.new.invoke(:init)

        time_now = Time.now

        expected_path_to_file = "#{tmpdir}/md/#{time_now.strftime('%Y%m%d')}-jackdaws-love-my-big-sphinx-of-quartz.md"
        expected_stdout = ForesiteRSpec.cli_line("Created file #{expected_path_to_file}")
        expected_file_content = <<~EOF
        # Jackdaws Love my Big Sphinx of Quartz

        #{time_now.strftime('%F')}

        EOF

        touch_args = ['Jackdaws Love my Big Sphinx of Quartz']

        expect { Foresite::Cli.new.invoke(:touch, touch_args) }.to output(expected_stdout).to_stdout
        expect(Pathname.new(expected_path_to_file)).to be_file
        expect(File.read(expected_path_to_file)).to eq(expected_file_content)
      end
    end

    it "should not duplicate an existing markdown file" do
      Dir.mktmpdir do |tmpdir|
        ENV['FORESITE_ROOT'] = tmpdir

        # Initialize before touching.
        Foresite::Cli.new.invoke(:init)

        time_now = Time.now

        # First touch.
        expected_path_to_file = "#{tmpdir}/md/#{time_now.strftime('%Y%m%d')}-jackdaws-love-my-big-sphinx-of-quartz.md"
        existing_file_content = <<~EOF
        # Jackdaws Love my Big Sphinx of Quartz

        #{time_now.strftime('%F')}

        Hear ye, hear ye.

        EOF

        touch_args = ['Jackdaws Love my Big Sphinx of Quartz']

        # First touch.
        Foresite::Cli.new.invoke(:touch, touch_args)
        File.write(expected_path_to_file, existing_file_content)

        # Second touch.
        expected_stdout = ForesiteRSpec.cli_line("File #{expected_path_to_file} already exists")

        expect { Foresite::Cli.new.invoke(:touch, touch_args) }.to output(expected_stdout).to_stdout
        expect(File.read(expected_path_to_file)).to eq(existing_file_content)
      end
    end
  end

  describe "build" do
    # @todo Need fixtures
    it "should generate HTML files from markdown files"
    it "should generate an index HTML file listing all markdown files"
  end
end
