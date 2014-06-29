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

    def puts_banner
      puts ''
      puts 'CLI tool to interface with Google Drive'.colorize(:green)
      puts '======================================='.colorize(:green)
    end

    def puts_hint
      puts 'Hint: type \'help\'.'.colorize(:green)
    end

    def clear_screen
      system('clear') || system('cls')
    end

    def init_shell
      puts_banner
      authorize
      clear_screen
      puts_hint
    end

    def prints_prompt
      print 'gdsh> '.colorize(:light_blue)
    end

    ##
    # Command interpreter
    #
    def shell
      init_shell

      loop do
        prints_prompt
        params = parsed_inputs
        command = next_command(params)
        command.new(@client, params).execute
        break if command.terminal?
      end

      write_session_info_to_file
    end
  end
end
