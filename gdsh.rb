require 'google/api_client'
require 'launchy'
require 'json'

require_relative 'drive'
require_relative 'command'

##
# Implements a command interpreter to wrap Google Drive API.
#
class GDriveShell < DriveService
  include CommandFactory
  ##
  # Banner for shell
  #
  def banner
    puts ''
    puts 'CLI tool to interface with Google Drive'
    puts '======================================='
    puts 'Hint: type \'help\'.'
    puts ''
  end

  ##
  # Command interpreter
  #
  def shell
    banner
    authorize

    loop do
      print '> '
      command = next_command(@client)
      command.execute
      break if command.terminal?
    end
  end
end

# if run as standalone script, launch shell
if __FILE__ == $PROGRAM_NAME
  filename = ARGV.first if ARGV.length > 0
  s = GDriveShell.new(filename)
  s.shell
end
