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
      klass = resolve_class(tokens.first)
      klass.new(*tokens[1..-1])
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
      if string.include? ','
        from_csv(string)
      else
        string
      end
    end

    def self.resolve_class(class_name)
      class_name.split('::').reduce(Kernel) { |parent, element| parent.const_get(element) }
    end
  end

end
