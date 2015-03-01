require 'open-uri'
require 'jsonapi/document'

module Jsonapi
  class Session

    attr_reader :config
    attr_reader :stack
    attr_reader :cache

    def initialize(config = {})
      @config = config
      @stack  = []
      @cache  = Hash.new {|hash, key| hash[key] = {"*" => []} }
    end

    def curr
      stack.last || empty_document
    end

    def _get(uri)
      uri = URI.parse(uri) unless uri.kind_of?(URI)

      json_str = \
      case uri.scheme
      when "file", nil
        File.read(uri.path)
      when "http", "https"
        open(uri) {|f| f.read }
      else
        raise "GET error: #{uri.inspect} (unsupported schema)"
      end

      Document.create(self, json_str)
    end

    def get(uri)
      push _get(uri)
    end

    def push(document)
      document.insert_into(cache)
      stack.push document
      self
    end

    def pop
      document = stack.pop
      document.remove_from(cache)
      document
    end

    def select(address)
      path = [address].compact
      path.inject(curr.resources) do |resources, selector|
        resources.map do |resource|
          resource.select(selector)
        end.flatten
      end
    end

    private

    def empty_document
      @empty_document ||= Document.create(self)
    end
  end
end
