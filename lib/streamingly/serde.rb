require 'bigdecimal'
require 'csv'

module Streamingly

  module SerDe
    def self.to_csv(record)
      case record
      when String
        record
      when Streamingly::KV
        record.to_s
      when Struct
        tokens = *record.map { |token|
          case token
          when BigDecimal
            token.to_s('F')
          else
            token
          end
        }

        CSV.generate_line( [ record.class.name, *tokens ]).rstrip
      end
    end

    def self.from_csv(string)
      tokens = CSV.parse_line(string)
      return unless tokens.size > 0
      klass = resolve_class(tokens.first)
      tokens_arr = tokens.to_a
      tokens_arr.pop while tokens_arr.last.nil?
      tokens_arr.shift  # Remove leading class marker
      klass.new(*tokens_arr)
    rescue NameError
      tokens
    end

    def self.from_tabbed_csv(string)
      k, v = string.split("\t", 2)
      return if k.nil? || v.nil?
      key = from_string_or_csv(k)
      value = if v.include? "\t"
                from_tabbed_csv(v)
              else
                from_string_or_csv(v)
              end
      KV.new(key, value)
    end

    def self.from_string_or_csv(string)
      if string.include? ','  # Likely a CSV
        from_csv(string)  # Attempt to parse
      else
        string
      end
    rescue CSV::MalformedCSVError  # Not actually CSV, fallback to string
      string
    end

    def self.resolve_class(class_name)
      class_name.split('::').reduce(Kernel) { |parent, element| parent.const_get(element) }
    end
  end

end
