module Rationalist
  VERSION = '2.0.0'

  def self.parse(args = ARGV, **options, &unknown_block)
    Argv.new(args, options, unknown_block).argv
  end

  class Argv
    attr_reader :argv

    private

    def initialize(args, options = {}, unknown_block = nil)
      @args          = args
      @options       = options
      @unknown_block = unknown_block
      @bools         = {}
      @strings       = {}
      @all_bools     = false
      @aliases       = {}
      @not_flags     = []
      @argv          = {_: []}

      apply_boolean_option!
      apply_alias_option!
      apply_strings_option!
      apply_defaults_option!

      parse_arguments!

      fill_with_defaults!
      fill_with_non_flags!
    end

    def apply_boolean_option!
      if @options[:boolean] == true
        @all_bools = true
      else
        Array(@options[:boolean] || []).each{ |b| @bools[b.to_sym] = true }
      end
    end

    def apply_alias_option!
      Array(@options[:alias] || {}).each{ |key, value|
        key = key.to_sym
        @aliases[key] = value.is_a?(Array) ? value.map(&:to_sym) : value.to_sym
        Array(@aliases[key]).each{ |x|
          x = x.to_sym
          @aliases[x] = [key] + Array(@aliases[key]).select{ |y| x != y }
        }
      }
    end

    def apply_strings_option!
      Array(@options[:string] || []).each{ |s|
        s = s.to_sym
        @strings[s] = true
        @strings[@aliases[s]] = true if @aliases[s]
      }
    end

    def apply_defaults_option!
      @defaults = @options[:default] || {}
      @bools.keys.each{ |key|
        set_argument key, @defaults.has_key?(key) ? @defaults[key] : false
      }
    end

    def parse_arguments!
      if i = @args.index('--')
        @not_flags, @args = @args[i+1..-1], @args[0..i-1]
      end

      i = 0
      while i < @args.length
        skip_next = false

        case arg = @args[i]
        when /\A--([^=]+)=(.*)\z/m
          set_argument($1, $2, arg)
        when /\A--no-(.+)/
          set_argument($1, false, arg)
        when /\A--(.+)/
          key = $1.to_sym
          next_arg = @args[i+1]
          skip_next = handle_dash_dash_argument(
            key,
            next_arg,
            arg,
            next_arg_is_value?(key, next_arg, /\A-/, false)
          )
        when /\A-[^-]+/
          skip_next = handle_dash_argument(arg.to_sym, @args[i+1])
        else
          if handle_unknown_argument(arg.to_s)
            @argv[:_] += @args[i+1 .. -1]
            break
          end
        end

        i += 1 if skip_next
        i += 1
      end
    end

    def handle_dash_dash_argument(key, next_arg, arg, next_arg_is_value)
      if next_arg_is_value
        set_argument(key, next_arg, arg)
        true
      elsif next_arg =~ /\A(true|false)\z/
        set_argument(key, $& == "true", arg)
        true
      else
        set_argument(key, @strings[key] ? '' : true, arg)
        false
      end
    end

    def handle_dash_argument(arg, next_arg)
      letters = arg[1..-1].split('')
      broken = false
      j = -1
      while j < letters.size - 2
        j += 1
        letter = letters[j].to_sym
        next_letters = arg[j+2 .. -1]
        if next_letters.to_sym == :-
          set_argument letter, next_letters, arg
          next
        end

        if letter =~ /[A-Za-z]/ && next_letters =~ /-?\d+(\.\d*)?(e-?\d+)?\z/
          set_argument letter, next_letters, arg
          broken = true
          break
        end

        next_letter = letters[j+1]
        if next_letter && next_letter =~ /\W/
          set_argument letter, arg[j+2 .. -1], arg
          broken = true
          break
        else
          set_argument letter, @strings[letter] ? '' : true, arg
        end
      end

      key = arg[-1].to_sym
      if !broken && key != :-
        return handle_dash_dash_argument(
          key,
          next_arg,
          arg,
          next_arg_is_value?(key, next_arg, /\A(-|--)[^-]/, true)
        )
      end

      false
    end

    def handle_unknown_argument(arg)
      if !@unknown_block || @unknown_block[arg.to_s]
        @argv[:_] << ((@strings[:_] || !numeric?(arg)) ? arg : Numeric(arg))
      end

      !!@options[:stop_early]
    end

    def fill_with_defaults!
      @defaults.each{ |key, value|
        split_key_array = split_key_at_dots(key)
        unless has_nested_key?(split_key_array)
          set_key(split_key_array, value)
          Array(@aliases[key] || []).each{ |sub_key|
            split_sub_key_array = split_key_at_dots(sub_key)
            set_key(split_sub_key_array, value)
          }
        end
      }
    end

    def fill_with_non_flags!
      if @options[:'--']
        @argv[:'--'] = []
        @not_flags.each{ |key| @argv[:'--'] << key }
      else
        @not_flags.each{ |key| @argv[:_] << key }
      end
    end

    def argument_defined?(key, arg)
      @all_bools && /\A--[^=]+\z/ =~ arg || @strings[key] || @bools[key] || @aliases[key]
    end

    def set_argument(key, value, arg = nil)
      return if arg && @unknown_block && !argument_defined?(key, arg.to_sym) && !@unknown_block[arg.to_s]
      value = (!@strings[key] && numeric?(value)) ? Numeric(value) : value
      split_key = split_key_at_dots(key)
      set_key(split_key, value)
      Array(@aliases[key] || []).each{ |sub_key|
        split_sub_key_array = split_key_at_dots(sub_key)
        set_key(split_sub_key_array, value)
      }
    end

    def set_key(keys, value)
      o = @argv
      keys[0..-2].each{ |key|
        key = to_key_type(key)
        o[key] = {} unless o.has_key?(key)
        o = o[key]
      }

      key = to_key_type(keys[-1])

      if !o.has_key?(key) || @bools[key] || o[key] == true || o[key] == false
        o[key] = value
      elsif o[key].is_a? Array
        o[key] << value
      else
        o[key] = [o[key], value]
      end
    end

    def next_arg_is_value?(key, next_arg, next_arg_regex, all_bools_true = true)
      next_arg &&
      next_arg !~ next_arg_regex &&
      !@bools[key] &&
      (all_bools_true || !@all_bools) &&
      (@aliases[key] ? !(Array(@aliases[key]).any?{ |a| @bools[a] }) : true)
    end

    def numeric?(value)
      value.is_a?(Numeric) ||
      !(value !~ /\A0x[0-9a-f]+\z/) ||
      !(value !~ /\A[-+]?(?:\d+(?:\.\d*)?|\.\d+)(e[-+]?\d+)?\z/)
    end

    def Numeric(value)
      case value
      when Numeric
        value
      when /\A0x/
        Integer(value)
      when /\.|e/
        Float(value)
      else
        Integer(value)
      end
    end

    def to_key_type(key)
      numeric?(key.to_s) ? Numeric(key.to_s) : key.to_sym
    end

    def split_key_at_dots(key)
      if key.is_a?(Symbol) || key.is_a?(String)
        key.to_s.split('.').map(&:to_sym)
      else
        Array(key)
      end
    end

    def has_nested_key?(split_key_array)
      catch :has_not do
        split_key_array.reduce(@argv){ |acc, cur| (acc.has_key?(cur) or throw :has_not) && acc[cur] }
        return true
      end

      false
    end
  end
end
