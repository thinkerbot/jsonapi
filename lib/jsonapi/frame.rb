require 'jsonapi/document'

module Jsonapi
  class Frame
    attr_reader :document
    attr_reader :path

    def initialize(document)
      @document = document
      @path = []
    end

    def selection
      path.inject([document.resources]) do |resources, selector|
        resources.map do |resource|
          resource.select(selector)
        end.flatten
      end
    end
  end
end