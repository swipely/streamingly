module Streamingly

  class SerDeIterable
    def initialize(iterable, error_handler = nil)
      @iterable = iterable
      @error_handler = error_handler
      @error_callback_defined = @error_handler &&
                                @error_handler.method_defined?(:on_error)
    end

    def each
      @iterable.each do |line|
        begin
          yield Streamingly::SerDe.from_tabbed_csv(line)
        rescue => error
          if @error_callback_defined
            @error_handler.send(:on_error, error, line: line)
          else
            raise error
          end
        end
      end
    end
  end

end
