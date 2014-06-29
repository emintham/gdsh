require 'differ'

require_relative 'commands'
require_relative 'get_file'

module Commands
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
      @all = @low_rev.nil? && @high_rev.nil?

      return if @all || @high_rev > @low_rev
      @low_rev, @high_rev = @high_rev, @low_rev
    end

    def consecutive_revisions
      return unless @all
      keys = modifying_users.keys.map { |x| x.to_i }.sort
      len = keys.length
      keys.first(len - 1).zip(keys.last(len - 1))
    end

    def compare_two_revs(low, high)
      first = download_revision_as_txt(low)
      second = download_revision_as_txt(high)
      Differ.diff_by_word(first, second)
    end

    def print_summary_of_changes(changes)
      puts "#{changes.change_count} words changed, #{changes.insert_count} inserts, #{changes.delete_count} deletes."
    end

    def compare_and_print_change_count(low, high)
      changes = compare_two_revs(low, high)
      print_summary_of_changes(changes)
    end

    def execute
      puts "Note: 'ab' -> 'ac' counts as both an insert and a delete but counts as only one change."
      if @all
        users = modifying_users
        consecutive_revisions.each do |pair|
          puts "From rev #{pair[0]} to rev #{pair[1]} modified by #{users[pair[0].to_s]}"
          compare_and_print_change_count(pair[0].to_s, pair[1].to_s)
        end
      else
        compare_and_print_change_count(@low_rev.to_s, @high_rev.to_s)
      end
    end
  end
end
