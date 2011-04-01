require 'fileutils'

module Cigarillo
  module Utils
    class CheckoutCleaner
      def checkout_root
        @checkout_root ||= Cigarillo.workbench+'checkouts'
      end

      def old_checkouts
        now = Time.now
        max_age = 2 * 24*3500 # 2 days

        Pathname.glob(checkout_root+'*').select {|c| now-c.ctime > max_age}
      end

      def clean!
        old_checkouts.each do |checkout|
          FileUtils.rm_rf(checkout)
        end
      end
    end
  end
end
