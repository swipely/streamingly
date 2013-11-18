module Streamingly
  class Reducer

    def initialize(accumulator_class, accumulator_options=nil)
      @accumulator_class = accumulator_class
      @accumulator_options = accumulator_options
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
        @accumulator = new_accumulator(key)
      end

      @accumulator.apply_value(value)

      results || []
    end

    def new_accumulator(key)
      if @accumulator_options
        @accumulator_class.new(key, @accumulator_options)
      else
        @accumulator_class.new(key)
      end
    end
  end
end
