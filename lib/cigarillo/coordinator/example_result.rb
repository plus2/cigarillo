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
        if file.is_a?(Hash)
          file = self.file['path']
        end

        file ||= ''
        file.sub(/\.eg\.rb$/,'')
      end
    end
  end
end
