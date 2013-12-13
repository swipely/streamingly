module Streamingly

  class KV < Struct.new(:key, :value)
    def to_s
      [ SerDe.to_csv(key), SerDe.to_csv(value) ].join("\t")
    end

    # TODO: remove .strip from https://github.com/swipely/streamingly/blob/master/lib/streamingly/reducer.rb#L11
    def strip
      self
    end

    # TODO: remove .split from https://github.com/swipely/streamingly/blob/master/lib/streamingly/reducer.rb#L28
    def split(char="\t")
      [key, value]
    end
  end

end
