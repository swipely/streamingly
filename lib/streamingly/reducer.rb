module Streamingly
  class Reducer

    def initialize(accumulator_class, accumulator_options = nil)
      @accumulator_class = accumulator_class
      @accumulator_options = accumulator_options
      @error_callback_defined = @accumulator_class.method_defined?(:on_error)
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
    rescue StandardError => error
      on_error(error, {})
      []
    end

    def reduce(line)
      # Streaming Hadoop only treats the first tab as the delimiter between
      # the key and value.  Additional tabs are grouped into the value:
      # http://hadoop.apache.org/docs/r0.18.3/streaming.html#How+Does+Streaming+Work
      key, value = line.split("\t", 2)

      if @prev_key != key
        results = flush

        @prev_key = key
        @accumulator = new_accumulator(key)
      end

      @accumulator.apply_value(value)

      results || []
    rescue StandardError => error
      on_error(error, { :line => line })
      []
    end

    def on_error(error, error_context)
      raise error unless @error_callback_defined && !@accumulator.nil?
      @accumulator.on_error(error, error_context)
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
