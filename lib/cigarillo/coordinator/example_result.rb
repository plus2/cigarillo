module Cigarillo
  module Coordinator
    module ExampleResult
      def result?
        key?('succeeded')
      end

      def succeeded?
        !! succeeded
      end

      def name
        file.sub(/\.eg\.rb$/,'')
      end
    end
  end
end
