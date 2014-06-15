require 'google/api_client'
require 'json'
require 'differ/diff'

require_relative 'mime'

##
# Commands
#
module Commands
  ##
  # Command mixin
  #
  module CommandMixin
    def execute
      fail 'Method not implemented.'
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def command_name
      end

      def function
      end

      def description
        command_name + parameters + ': ' + function
      end

      def terminal?
        false
      end
    end
  end

  ##
  # Command with an initialized client object.
  #
  class Command
    include CommandMixin

    def initialize(client, params)
      @client, @params = client, params
    end
  end

  ##
  # Unrecognized command.
  #
  class Unrecognized < Command
    def execute
      "Command not recognized, got: #{@params}"
    end
  end

  ##
  # Help command
  #
  class Help < Command
    def initialize(client, params)
    end

    def self.command_name
      'help'
    end

    def self.function
      'Returns this usage information.'
    end

    def execute
      puts Commands.usage
    end
  end

  ##
  # Quit command.
  #
  class Quit < Command
    def initialize(client, params)
    end

    def self.command_name
      'quit'
    end

    def self.function
      'Exit the application.'
    end

    def terminal?
      true
    end

    def execute
    end
  end

  ##
  # Clear screen.
  #
  class Clear < Command
    def initialize(client, params)
    end

    def self.command_name
      'clear'
    end

    def self.function
      'Clears the screen.'
    end

    def execute
      system('clear') || system('cls')
    end
  end

  ##
  # List all files accessible by the application.
  #
  class ListFiles < Command
    def self.command_name
      'ls'
    end

    def self.function
      'List files accessible by this application.'
    end

    def retrieve_file_by_page_token(pagetoken)
      parameters = pagetoken.to_s.empty? ? {} : { pageToken: pagetoken }
      drive = @client.discovered_api('drive', 'v2')
      @client.execute(
        api_method: drive.files.list,
        parameters: parameters)
    end

    def filelist
      puts 'Retrieving list of files accessible...'

      result = []
      page_token = nil

      loop do
        api_result = retrieve_file_by_page_token(page_token)

        if api_result.status == 200
          files = api_result.data
          result.concat(files.items)
          page_token = files.next_page_token
        else
          puts "An error occurred: #{result.data['error']['message']}"
          page_token = nil
        end

        break if page_token.to_s.empty?
      end

      result
    end

    ##
    # Prints out a list of files and their properties (title, id,
    # date uploaded).
    #
    def execute
      filelist.each do |f|
        puts "Title: #{f['title']}"
        puts "id: #{f['id']}"
        puts "created at: #{f['createdDate']}"
        puts ''
      end
    end
  end

  ##
  # Uploads a template to the Drive.
  #
  class UploadTemplate < Command
    include Mime

    def self.command_name
      'upload_template'
    end

    def self.function
      'Uploads a template to the Drive.'
    end

    def insert_schema(title, description, mimetype)
      drive = @client.discovered_api('drive', 'v2')
      drive.files.insert.request_schema.new(
        title: title,
        description: description,
        mimeType: mimetype)
    end

    def insert_file(filename, file, mimetype)
      drive = @client.discovered_api('drive', 'v2')
      media = Google::APIClient::UploadIO.new(filename, mimetype)
      @client.execute(
        api_method: drive.files.insert,
        body_object: file,
        media: media,
        parameters: {
          uploadType: 'multipart',
          convert: 'true',
          alt: 'json' })
    end

    ##
    # Writes a template file to drive.
    #
    def execute
      filename = '../document.txt'
      return unless @client && File.exist?(filename)

      puts 'Writing template to drive.'
      file = insert_schema('My Document', 'A test document', txt)
      insert_file(filename, file, txt)
    end
  end

  ##
  # Queries all revisions of a file.
  #
  class QueryRevision < Command
    include Mime

    def self.command_name
      'query'
    end

    def self.parameters
      '(<file_id>)'
    end

    def self.function
      'Queries all revisions of a file.'
    end

    def initialize(client, params)
      super(client, params)
      @file_id = params[1]
    end

    def revisions
      drive = @client.discovered_api('drive', 'v2')
      api_result = @client.execute(
        api_method: drive.revisions.list,
        parameters: { 'fileId' => @file_id })
      if api_result.status == 200
        api_result.data.items
      else
        puts "An error occurred: #{result.data['error']['message']}"
      end
    end

    ##
    # Print consolidated revisions of a file
    #
    def execute
      return if revisions.nil?

      puts 'Revisions:'
      revisions.each do |r|
        puts "Revision id: #{r['id']}"
        puts "Modified: #{r['modifiedDate']}"
        puts "Modifying User: #{r['lastModifyingUserName']}"
        puts "Download pdf: #{r['exportLinks'][pdf]}"
        puts "Download docx: #{r['exportLinks'][docx]}"
        puts ''
      end
    end

    def txt_link(revision)
      rev = revisions.select { |r| r['id'] == revision }
      # should only have one element if revision exists
      rev.first['exportLinks'][txt] unless rev.empty?
    end

    def modifying_users
      revisions.map { |r| [r['lastModifyingUserName'], r['id']] }
    end
  end

  ##
  # Downloads Files/Revisions
  #
  class GetFile < QueryRevision
    def self.command_name
      'get'
    end

    def self.parameters
      '(<file_id>[,<revision_number>])'
    end

    def self.function
      'Downloads a specific revision of a file if <revision_number> is ' \
      'specified; downloads all revisions otherwise.'
    end

    def initialize(client, params)
      super(client, params)
      @revision = (params.length == 3) ? params[2] : nil
    end

    def download(url)
      return unless @client

      puts "Downloading #{url} ..."
      result = @client.execute(uri: url)
      if result.status == 200
        result.body
      else
        puts "An error occurred: #{result.data['error']['message']}"
      end
    end

    def download_revision_as_txt(rev)
      download(txt_link(rev))
    end

    def write_to_file(revision)
      filename = generate_filename_from_revision(revision)
      File.write(filename, download_revision_as_txt(revision))
    end

    def generate_filename_from_revision(revision)
      @params[1] + '_rev_' + revision + '.txt'
    end

    def execute
      if @revision.nil?
        revisions.each { |r| write_to_file(r['id']) }
      else
        write_to_file(@revision)
      end
    end
  end

  ##
  # Summarizes changes between revisions
  #
  class RevisionDiff < GetFile
    def self.command_name
      'diff'
    end

    def self.parameters
      '(<file_id>[, <rev_1>, <rev_2>])'
    end

    def self.function
      'Compares and summarizes the changes between two revisions. If no' \
      'revision numbers are provided, a consolidated summary is returned.'
    end

    def initialize(client, params)
      super(client, params)
      @low_rev = (params.length == 4) ? params[2].to_i : nil
      @high_rev = (params.length == 4) ? params[3].to_i : nil
      @modifying_users = modifying_users
      @all = false

      return unless @high_rev < @low_rev
      @low_rev, @high_rev = @high_rev, @low_rev
    end
  end

  module_function

  def commands
    constants.select { |c| const_get(c).is_a? Class }
  end

  def usage
    puts 'Commands'
    puts '--------'
    commands.each do |c|
      puts const_get(c).description
    end
  end

  def interpret(input)
    commands.each do |c|
      return const_get(c) if input == const_get(c).command_name
    end

    return Quit if input == '' || input.nil?
    return Unrecognized
  end
end