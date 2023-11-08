module LibUI
  # This module overrides Fiddle's mtehods
  # - Fiddle::Importer#extern
  # - Fiddle::CParser#parse_signature
  # Original methods are in
  # - https://github.com/ruby/fiddle/blob/master/lib/fiddle/import.rb
  # - https://github.com/ruby/fiddle/blob/master/lib/fiddle/cparser.rb
  # These changes add the ability to parse the signatures of functions given as arguments.

  module FiddlePatch
    def parse_signature(signature, tymap = nil)
      tymap ||= {}
      ctype, func, args = case compact(signature)
                          when /^(?:[\w\*\s]+)\(\*(\w+)\((.*?)\)\)(?:\[\w*\]|\(.*?\));?$/
                            [TYPE_VOIDP, Regexp.last_match(1), Regexp.last_match(2)]
                          when /^([\w\*\s]+[*\s])(\w+)\((.*?)\);?$/
                            [parse_ctype(Regexp.last_match(1).strip, tymap), Regexp.last_match(2), Regexp.last_match(3)]
                          else
                            raise("can't parserake the function prototype: #{signature}")
                          end
      symname = func
      callback_argument_types = {}                                              # Added
      argtype = split_arguments(args).collect.with_index do |arg, idx|          # Added with_index
        # Check if it is a function pointer or not
        if arg =~ /\(\*.*\)\(.*\)/                                              # Added
          # From the arguments, create a notation that looks like a function declaration
          # int(*f)(int *, void *) -> int f(int *, void *)
          func_arg = arg.sub('(*', ' ').sub(')', '')                            # Added
          # Use Fiddle's parse_signature method again.
          callback_argument_types[idx] = parse_signature(func_arg)              # Added
        end
        parse_ctype(arg, tymap)
      end
      # Added callback_argument_types. Original method return only 3 values.
      [symname, ctype, argtype, callback_argument_types]
    end

    def extern(signature, *opts)
      symname, ctype, argtype, callback_argument_types = parse_signature(signature, type_alias)
      opt = parse_bind_options(opts)
      func = import_function(symname, ctype, argtype, opt[:call_type])

      # callback_argument_types
      func.instance_variable_set(:@callback_argument_types, 
                                   callback_argument_types) # Added
      # attr_reader
      def func.callback_argument_types
        @callback_argument_types
      end

      # argument_types
      # Ruby 2.7 Fiddle::Function dose not have @argument_types
      # Ruby 3.0 Fiddle::Function has @argument_types
      if func.instance_variable_defined?(:@argument_types)
        # check if @argument_types are the same
        if func.instance_variable_get(:@argument_types) != argtype
          warn "#{symname} func.argument_types:#{func.argument_types} != argtype #{argtype}"
        end
      else
        func.instance_variable_set(:@argument_types, argtype)
      end
      # attr_reader
      def func.argument_types
        @argument_types
      end

      name = symname.gsub(/@.+/, '')
      @func_map[name] = func
      # define_method(name){|*args,&block| f.call(*args,&block)}
      begin
        /^(.+?):(\d+)/ =~ caller.first
        file = Regexp.last_match(1)
        line = Regexp.last_match(2).to_i
      rescue StandardError
        file, line = __FILE__, __LINE__ + 3
      end
      module_eval(<<-EOS, file, line)
        def #{name}(*args, &block)
          @func_map['#{name}'].call(*args,&block)
        end
      EOS
      module_function(name)
      func
    end
  end
  private_constant :FiddlePatch
end
