module Streamingly
  class Reducer

    def initialize(accumulator_class)
      @accumulator_class = accumulator_class
    end

    def reduce_over(enumerator)
      enumerator.each do |line|
        reduce(line.strip).each do |out|
          yield out
        end
      end

      flush.each do |out|
        yield out
      end
    end

  private

    def flush
      @accumulator ? @accumulator.flush : []
    end

    def reduce(line)
      key, value = line.split("\t")

      if @prev_key != key
        results = flush

        @prev_key = key
        @accumulator = @accumulator_class.new(key)
      end

      @accumulator.apply_value(value)

      results || []
    end

  end
end
