require "tmpdir"
require "pathname"

RSpec.describe Foresite::Cli do
  describe "init" do
    it "should display error for nonexistent directory and exit 1" do
      expect {
        Foresite::Cli.new.invoke(:init, [], {
          d: "foo"
        })
      }.to output("Nonexistent directory foo\n").to_stderr.and(raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end)
    end

    it "should display error for non-writable directory and exit 1" do
      expected_stderr = ForesiteRSpec.cli_line("Cannot write to directory /usr")

      expect {
        Foresite::Cli.new.invoke(:init, [], {
          d: "/usr"
        })
      }.to output(expected_stderr).to_stderr.and(raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end)
    end

    it "should create the md directory and copy the sample template" do
      Dir.mktmpdir do |tmpdir|
        expected_stdout = ForesiteRSpec.cli_lines([
          "Created directory #{tmpdir}/md",
          "Created directory #{tmpdir}/out",
          "Created file #{tmpdir}/template.rhtml"
        ])

        expect {
          command = :init
          command_args = []
          command_options = {
            d: tmpdir
          }

          Foresite::Cli.new.invoke(command, command_args, command_options)

          expect(Pathname.new("#{tmpdir}/md")).to be_directory
          expect(Pathname.new("#{tmpdir}/out")).to be_directory
          expect(Pathname.new("#{tmpdir}/template.rhtml")).to be_file

          expect(Dir.new("#{tmpdir}/md").children).to eq([])
          expect(Dir.new("#{tmpdir}/out").children).to eq([])
        }.to output(expected_stdout).to_stdout
      end
    end

    it "should not overwrite existing files" do
      Dir.mktmpdir do |tmpdir|
        expected_stdout = ForesiteRSpec.cli_lines([
          "Directory #{tmpdir}/md already exists",
          "Directory #{tmpdir}/out already exists",
          "File #{tmpdir}/template.rhtml already exists"
        ])

        # Invoke first time.
        Foresite::Cli.new.invoke(:init, [], {
          d: tmpdir
        })

        # Invoke second time.
        expect {
          Foresite::Cli.new.invoke(:init, [], {
            d: tmpdir
          })
        }.to output(expected_stdout).to_stdout
      end
    end
  end

  describe "touch" do
    it "should generate a blank markdown file"
  end

  describe "build" do
    # @todo Need fixtures
    it "should generate HTML files from markdown files"
    it "should generate an index HTML file listing all markdown files"
  end
end
