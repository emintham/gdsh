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
        puts drive_error_string
      end
    end

    def puts_banner
      puts 'Revisions'.colorize(:magenta)
      puts '---------'.colorize(:magenta)
    end

    def revision_id_label
      "Revision id: ".colorize(:magenta)
    end

    def modified_date_label
      "Modified: ".colorize(:magenta)
    end

    def modifying_user_label
      "Modifying User: ".colorize(:magenta)
    end

    def pdf_link_label
      "Download pdf: ".colorize(:magenta)
    end

    def docx_link_label
      "Download docx: ".colorize(:magenta)
    end

    def txt_link_label
      "Download txt: ".colorize(:magenta)
    end

    def puts_download_links(revision)
      puts pdf_link_label + "#{revision['exportLinks'][pdf]}"
      puts docx_link_label + "#{revision['exportLinks'][docx]}"
      puts txt_link_label + "#{revision['exportLinks'][txt]}"
    end

    def puts_revision_info(revision)
      puts revision_id_label + "#{revision['id']}"
      puts modified_date_label + "#{revision['modifiedDate']}"
      puts modifying_user_label + "#{revision['lastModifyingUserName']}"
      puts_download_links
      puts ''
    end

    def execute
      return if revisions.nil?

      puts_banner
      revisions.each do |r|
        puts_revision_info(r)
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
