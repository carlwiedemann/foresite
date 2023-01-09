RSpec.describe Foresite::Cli do
  it 'should be run' do
    expect {
      command = :pluralize
      command_args = ['tom']
      command_options = { date: '20150626' }

      Foresite::Cli.new.invoke(command, command_args, command_options)
    }.to output('Hello tom on 20150626').to_stdout
  end
end
