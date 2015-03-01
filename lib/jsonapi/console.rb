require 'jsonapi/session'
require 'irb'

module Jsonapi
  class Console
    attr_reader :session

    def initialize(session)
      @session = session
    end

    def start_irb
      IRB.setup nil
      IRB.conf[:MAIN_CONTEXT] = IRB::Irb.new.context
      require 'irb/ext/multi-irb'
      IRB.irb nil, self
    end

    # Errors

    def handle_error(error)
      raise error
    end

    # Navigation

    def curr
      session.curr
    end

    def get(url)
      session.get(url)
      curr
    rescue
      handle_error $!
    end
  end
end
