RSpec.describe Foresite::Cli do
  # it "should be run" do
  #   expect {
  #     command = :say_hello
  #     command_args = ["tom"]
  #     command_options = {}
  #
  #     Foresite::Cli.new.invoke(command, command_args, command_options)
  #   }.to output("Hello tom\n").to_stdout
  # end

  it "should display error for nonexistent directory and exit 1" do
    expect {
      command = :init
      command_args = []
      command_options = {
        d: "foo"
      }

      Foresite::Cli.new.invoke(command, command_args, command_options)
    }.to output("Nonexistent directory foo\n").to_stderr.and(raise_error(SystemExit) do |error|
      expect(error.status).to eq(1)
    end)
  end

  # it "should generate a blank markdown file" do
  #
  # end
  #
  # it "should generate HTML files from markdown files" do
  #
  # end
end
