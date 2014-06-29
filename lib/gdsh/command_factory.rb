require_relative 'commands'
require_relative 'clear'
require_relative 'help'
require_relative 'list_files'
require_relative 'query_revision'
require_relative 'quit'
require_relative 'unrecognized'
require_relative 'upload_template'
require_relative 'get_file'
require_relative 'revision_diff'

##
# Factory pattern to create the appropriate command.
#
module CommandFactory
  include Commands

  def parsed_inputs
    # gets user input, defaulting to empty and removing newline
    user_input = $stdin.gets || ''

    # if command has parameters, split it up
    user_input.chomp.split(/[\(,\),\,,\ ]/)
  end

  def next_command(params)
    Commands.interpret(params[0])
  end
end
