require 'bigdecimal'
require 'csv'

module Streamingly

  module SerDe
    def self.to_csv(record)
      case record
      when String
        record
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
      k,v = string.force_encoding('utf-8').split("\t")
      KV.new(from_csv(k), from_csv(v))
    end

    def self.resolve_class(class_name)
      class_name.split('::').reduce(Kernel) { |parent, element| parent.const_get(element) }
    end
  end

end
