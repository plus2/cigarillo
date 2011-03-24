require 'yajl'

module Cigarillo
  module Utils
    class StructuredProgress
			def initialize(progress)
        @progress = progress

        @buffer = ""

        setup_parser!
      end


      def setup_parser!
        this = self

        @parser = Yajl::Parser.new
        @parser.on_parse_complete = lambda {|obj| this.add_obj(obj)}
      end


      def add(tag, data)
        if tag == :out
          (@buffer ||= '') << data
          process_buffer
        end
      end


      def process_buffer
        while n = @buffer.index("\n")
          line = @buffer[0..n-1]
          @buffer = @buffer[n+1..-1]

          begin
            @parser.parse(line)
          rescue Yajl::ParseError
            add_line(line)
            puts "ook #{$!.class}: #{$!}"
            setup_parser!
          end
        end
      end


      def add_line(line)
        @progress.info :out, line
      end

      def add_obj(obj)
        @progress.info :out, obj
      end
    end
  end
end
