RSpec.describe Foresite::Cli do
  it "should be run" do
    expect {
      command = :say_hello
      command_args = ["tom"]
      command_options = {}

      Foresite::Cli.new.invoke(command, command_args, command_options)
    }.to output("Hello tom\n").to_stdout
  end
end
