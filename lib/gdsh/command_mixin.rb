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

    ##
    # Every 'useful' Command class should override the following
    # (except terminal?)
    #
    module ClassMethods
      def command_name
        ''
      end

      def function
        ''
      end

      def parameters
        ''
      end

      def description
        command_name + parameters + ': ' + function
      end

      def terminal?
        false
      end
    end
  end
end
