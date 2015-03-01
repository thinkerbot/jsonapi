require 'jsonapi/resource_object'

module Jsonapi
  class Document < Resource
    class << self
      def default_json_obj
        {DATA_KEY => []}
      end
    end

    DATA_KEY   = "data"
    ERRORS_KEY = "errors"
    LINKED_KEY = "linked"

    def optional_keys
      super + [DATA_KEY, ERRORS_KEY, LINKED_KEY]
    end

    def data
      @data ||= array_fetch(DATA_KEY) {|key, json_obj| ResourceObject.new(json_obj, session) }
    end

    def errors
      @errors ||= array_fetch(ERRORS_KEY)
    end

    def linked
      @linked ||= array_fetch(LINKED_KEY) {|key, json_obj| ResourceObject.new(json_obj, session) }
    end

    def resources
      data + array_fetch(*attr_keys) {|key, json_obj| json_obj["type"] ||= key; ResourceObject.new(json_obj, session) }
    end

    def insert_into(cache)
      [data, linked].each do |source|
        source.each do |ro|
          cache[ro.type][ro.id] = ro
          cache[ro.type]["*"] << ro
        end
      end

      self
    end

    def remove_from(cache)
      [data, linked].each do |source|
        source.each do |ro|
          cache[ro.type][ro.id] = ro
          cache[ro.type]["*"] << ro
        end
      end

      self
    end

    private

    def array_fetch(*keys)
      keys.map do |key|
        objects = json_obj.fetch(key, [])
        objects = [objects] unless objects.kind_of?(Array)
        objects = objects.map {|obj| yield(key, obj) } if block_given?
        objects
      end.flatten
    end
  end
end
