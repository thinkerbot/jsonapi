require 'jsonapi/resource'

module Jsonapi
  class ResourceObject < Resource
    TYPE_KEY   = "type"
    ID_KEY     = "id"

    def type
      json_obj[TYPE_KEY]
    end

    def id
      json_obj[ID_KEY]
    end
  end
end
