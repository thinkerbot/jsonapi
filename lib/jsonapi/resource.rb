require 'json'

module Jsonapi
  class Resource
    class << self
      def create(session, json_obj = default_json_obj)
        unless json_obj.kind_of?(Hash)
          json_obj = JSON.load(json_obj)
        end

        new(json_obj, session)
      end

      def default_json_obj
        {}
      end
    end

    LINKS_KEY = "links"
    META_KEY  = "meta"

    attr_reader :json_obj
    attr_reader :session

    def initialize(json_obj, session)
      @json_obj = json_obj
      @session  = session
    end

    def required_keys
      []
    end

    def optional_keys
      [LINKS_KEY, META_KEY]
    end

    def attr_keys
      json_obj.keys - required_keys - optional_keys
    end

    def links
      @links ||= json_obj.fetch(LINKS_KEY, {})
    end

    def meta
      @meta ||= json_obj.fetch(META_KEY, {})
    end

    def select(selector)
      type, id = selector.split(':')
      id = "*"  if id.nil?
      session.cache[type][id]
    end

    def to_s
      json_obj.to_json
    end
  end
end