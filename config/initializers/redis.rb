REDIS_CONFIG = YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/redis.yml")).result, permitted_classes: [Symbol])[Rails.env].symbolize_keys

def get_redis(instance = :default)
  load_instance = REDIS_CONFIG.key?(instance.to_sym) ? instance.to_sym : :default
  Redis.new(REDIS_CONFIG[load_instance].symbolize_keys)
end
