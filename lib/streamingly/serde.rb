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
      klass = Kernel.const_get(tokens.first)
      klass.new(*tokens[1..-1])
    rescue NameError
      tokens
    end

    def self.from_tabbed_csv(string)
      k,v = string.split("\t")
      KV.new(from_csv(k), from_csv(v))
    end
  end

end
