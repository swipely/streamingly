require "streamingly/version"
require "streamingly/reducer"
require "streamingly/kv"
require "streamingly/serde"
require "streamingly/serde_iterable"

module Streamingly

  def self.kv(key, value)
    KV.new(key, value).to_s
  end

end
