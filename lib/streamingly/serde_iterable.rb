module Streamingly

  class SerDeIterable
    def initialize(iterable)
      @iterable = iterable
    end

    def each
      @iterable.each do |line|
        yield Streamingly::SerDe.from_tabbed_csv(line)
      end
    end
  end

end
