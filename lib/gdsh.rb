require 'google/api_client'
require 'launchy'
require 'json'

require_relative 'gdsh/version'
require_relative 'gdsh/drive'
require_relative 'gdsh/command_factory'

##
# Implements a command interpreter to wrap Google Drive API.
#
module Gdsh
  ##
  # Gdsh Class
  #
  class Gdsh < DriveService
    include CommandFactory

    def banner
      puts ''
      puts 'CLI tool to interface with Google Drive'
      puts '======================================='
    end

    def hint
      puts 'Hint: type \'help\'.'
    end

    def clear_screen
      system('clear') || system('cls')
    end

    def init_shell
      banner
      authorize
      clear_screen
      hint
    end

    ##
    # Command interpreter
    #
    def shell
      init_shell

      loop do
        print '> '
        command = next_command
        command.execute
        break if command.terminal?
      end
    end
  end
end
