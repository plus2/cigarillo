module Cigarillo
  module Integration
    class YmSetup
      def initialize(igor)
        @igor = igor
      end
      def call(env)
        @igor.call(env)
      end
    end
  end
end
