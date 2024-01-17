# frozen_string_literal: true

module RedisProgressCounter
  def cache_total_data_key
    "total_#{redis_counter_name}_#{current_hotel}_#{redis_counter_id}"
  end

  def cached_array_key
    "array_#{redis_counter_name}_#{current_hotel}_#{redis_counter_id}"
  end

  def cache_processed_key
    "processed_#{redis_counter_name}_#{current_hotel}_#{redis_counter_id}"
  end

  def cache_success_key
    "success_#{redis_counter_name}_#{current_hotel}_#{redis_counter_id}"
  end

  def cache_created_key
    "created_#{redis_counter_name}_#{current_hotel}_#{redis_counter_id}"
  end

  def cache_updated_key
    "updated_#{redis_counter_name}_#{current_hotel}_#{redis_counter_id}"
  end

  def cache_not_updated_key
    "not_updated_#{redis_counter_name}_#{current_hotel}_#{redis_counter_id}"
  end

  def cache_failed_key
    "error_#{redis_counter_name}_#{current_hotel}_#{redis_counter_id}"
  end

  def cached_error_data_key
    "error_data_#{redis_counter_name}_#{current_hotel}_#{redis_counter_id}"
  end

  def cache_total_data=(count)
    redis_cache.set cache_total_data_key, count
  end

  def cache_total_data
    redis_cache.get(cache_total_data_key).to_i
  end

  def cache_processed
    redis_cache.get(cache_processed_key).to_i
  end

  def incr_cache_processed
    redis_cache.incr(cache_processed_key)
  end

  def cache_processed=(value)
    redis_cache.incrby(cache_processed_key, value)
  end

  def cache_success
    redis_cache.get(cache_success_key).to_i
  end

  def incr_cache_success
    redis_cache.incr(cache_success_key)
  end

  def cache_created
    redis_cache.get(cache_created_key).to_i
  end

  def incr_cache_created
    redis_cache.incr(cache_created_key)
  end

  def cache_updated
    redis_cache.get(cache_updated_key).to_i
  end

  def incr_cache_updated
    redis_cache.incr(cache_updated_key)
  end

  def cache_not_updated
    redis_cache.get(cache_not_updated_key).to_i
  end

  def incr_cache_not_updated
    redis_cache.incr(cache_not_updated_key)
  end

  def cache_failed
    redis_cache.get(cache_failed_key).to_i
  end

  def incr_cache_failed
    redis_cache.incr(cache_failed_key)
  end

  def cached_array_data
    redis_cache.lrange(cached_array_key, 0, -1).map { |data| JSON.parse(data) }
  end

  def cached_array_data=(data)
    value = data.is_a?(Array) ? data.map(&:to_json) : data.to_json
    redis_cache.rpush cached_array_key, value
  end

  def cached_data_errors
    redis_cache.lrange(cached_error_data_key, 0, -1)
               .map { |data| JSON.parse(data) }
  end

  def cached_data_errors=(data)
    value = data.is_a?(Array) ? data.map(&:to_json) : data.to_json
    redis_cache.rpush cached_error_data_key, value
  end

  def redis_progress_state
    cache_total_data == cache_processed ? "done" : "running"
  end

  def sum_progress_data
    (cache_created + cache_updated + cache_not_updated + cache_failed)
  end

  def cache_response(options = {})
    { total_data: cache_total_data, current_count: cache_processed, **options }
  end

  def cache_complete_response(options = {})
    cache_response(
      success: cache_success,
      failed: cache_failed,
      errors: cached_data_errors,
      **options,
    )
  end

  def clear_redis_cache!
    redis_cache.del(cache_total_data_key)
    redis_cache.del(cache_processed_key)
    redis_cache.del(cache_success_key)
    redis_cache.del(cache_created_key)
    redis_cache.del(cache_updated_key)
    redis_cache.del(cache_not_updated_key)
    redis_cache.del(cache_failed_key)
    redis_cache.del(cached_error_data_key)
    redis_cache.del(cached_array_key)
  end

  def current_hotel
    @current_hotel ||= Hotel.current.schema
  end

  def redis_counter_name; end
  def redis_counter_id; end

  def redis_cache
    Rails.cache.redis
  end
end
