class CacheClearer
  include Sidekiq::Worker

  def perform(cache)
    if cache.is_a?(Hash)
      "Cache::#{cache["options"]["strategy"]}".constantize.new(cache["options"]).purge
    else
      cache.purge
    end
  end

  def self.push_to_queue(queue, data)
    self.client_push('class' => self, 'queue' => queue, 'args' => data)
  end
end
