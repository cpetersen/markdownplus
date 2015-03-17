module Markdownplus
  class HandlerRegistry
    @@registry = {}

    def self.handler_instance(name)
      handler_class(name).new if handler_class(name)
    end

    def self.handler_class(name)
      @@registry[name]
    end

    def self.register(name, handler)
      @@registry[name] = handler
    end
  end
end
