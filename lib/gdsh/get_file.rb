require_relative 'commands'
require_relative 'query_revision'

module Commands
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

    def puts_downloading_banner(url)
      puts "Downloading ".colorize(:cyan) + "#{url} ...".colorize(:light_yellow)
    end

    def download(url)
      return unless @client

      puts_downloading_banner(url)
      result = @client.execute(uri: url)
      if result.status == 200
        result.body
      else
        puts drive_error_string
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
end
