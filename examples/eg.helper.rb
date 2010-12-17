require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

$: << File.expand_path('../../lib',__FILE__)

require 'tapp'
require 'exemplor'
require 'angry_hash'

require 'awesome_print'
module Exemplor
  class AwesomeResultPrinter < ResultPrinter
    def format_info(str, result)
      icon(:info) + ' ' + str + "\n\e[0m" + result.ai(:indent => 2)
    end
  end

  Examples.printer = AwesomeResultPrinter
end


