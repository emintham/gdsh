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
      'Compares and summarizes the changes between two revisions. If no ' \
      'revision numbers are provided, a consolidated summary is returned.'
    end

    def initialize(client, params)
      super(client, params)
      init_revisions
    end

    def init_revisions
      @low_rev = (@params.length == 4) ? @params[2] : nil
      @high_rev = (@params.length == 4) ? @params[3] : nil
      @all = @low_rev.nil? && @high_rev.nil?
      return if @all || order_is_correct
      @low_rev, @high_rev = @high_rev, @low_rev
    end

    def order_is_correct
      @high_rev.to_i > @low_rev.to_i
    end

    def consecutive_revisions
      return unless @all
      keys = modifying_users.keys.sort_by { |x| x.to_i }
      len = keys.length
      keys.first(len - 1).zip(keys.last(len - 1))
    end

    def compare_two_revs(low, high)
      first = download_revision_as_txt(low)
      second = download_revision_as_txt(high)
      Differ.diff_by_word(first, second)
    end

    def print_summary_of_changes(changes)
      puts "#{changes.change_count} words changed, ".colorize(:green) +
      "#{changes.insert_count} inserts, ".colorize(:green) +
      "#{changes.delete_count} deletes.".colorize(:green)
    end

    def compare_and_print_change_count(low, high)
      changes = compare_two_revs(low, high)
      print_summary_of_changes(changes)
    end

    def puts_diff_note
      puts "Note: 'ab' -> 'ac' counts as both an insert and".colorize(:green) +
      ' a delete but counts as only one change.'.colorize(:green)
    end

    def execute
      puts_diff_note
      if @all
        consecutive_revisions.each do |pair|
          puts "From rev #{pair[0]} to rev #{pair[1]} ".colorize(:green) +
          "modified by #{modifying_users[pair[0]]}".colorize(:green)
          compare_and_print_change_count(pair[0], pair[1])
        end
      else
        compare_and_print_change_count(@low_rev, @high_rev)
      end
    end
  end
end
