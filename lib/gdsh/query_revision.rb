require_relative 'commands'
require_relative 'mime'

module Commands
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
        puts "An error occurred: #{result.data['error']['message']}".colorize(:red)
      end
    end

    def puts_banner
      puts 'Revisions'.colorize(:magenta)
      puts '---------'.colorize(:magenta)
    end

    ##
    # Print consolidated revisions of a file
    #
    def execute
      return if revisions.nil?

      puts_banner
      revisions.each do |r|
        puts "Revision id: ".colorize(:magenta) + "#{r['id']}"
        puts "Modified: ".colorize(:magenta) + "#{r['modifiedDate']}"
        puts "Modifying User: ".colorize(:magenta) + "#{r['lastModifyingUserName']}"
        puts "Download pdf: ".colorize(:magenta) + "#{r['exportLinks'][pdf]}"
        puts "Download docx: ".colorize(:magenta) + "#{r['exportLinks'][docx]}"
        puts "Download txt: ".colorize(:magenta) + "#{r['exportLinks'][txt]}"
        puts ''
      end
    end

    def txt_link(revision)
      rev = revisions.select { |r| r['id'] == revision }
      # should only have one element if revision exists
      rev.first['exportLinks'][txt] unless rev.empty?
    end

    def modifying_users
      modifying_hash = {}
      revisions.each do |r|
        modifying_hash[r['id']] = r['lastModifyingUserName']
      end
      modifying_hash
    end
  end
end
