module LibUI
  module Utils
    class << self
      def convert_to_ruby_method(original_method_name)
        underscore(original_method_name.delete_prefix('ui'))
      end

      # Converting camel case to underscore case in ruby
      # https://stackoverflow.com/questions/1509915/converting-camel-case-to-underscore-case-in-ruby#1509939
      def underscore(str)
        str.gsub(/::/, '/')
           .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .tr('-', '_')
           .downcase
      end
    end
  end
end
