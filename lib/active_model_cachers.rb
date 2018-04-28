require 'active_model_cachers/version'
require 'active_model_cachers/config'
require 'active_model_cachers/cache_service_factory'
require 'active_record'
require 'active_record/relation'

module ActiveModelCachers
  def self.config
    @config ||= Config.new
    yield(@config) if block_given?
    return @config
  end
end

class << ActiveRecord::Base
  def cache_at(column, query = nil)
    reflect = reflect_on_association(column)
    service_klass = ActiveModelCachers::CacheServiceFactory.create(reflect, "cacher_key_of_#{self}_at_#{column}", &query)
    after_commit ->{ service_klass.instance(id).clean_cache if previous_changes.key?(column) || destroyed? }

    define_singleton_method(:"#{column}_cachers") do
      service_klass
    end
  end
end
