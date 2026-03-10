# Dir["#{Rails.root}/app/models/callbacks/**/*.rb"].each do |callback_filepath|
#   model_clazz = callback_filepath.gsub(/(^.*callbacks\/|\_callbacks.rb)/, '')
#   model_class = model_clazz.camelize.constantize
#   callback_clazz = "callbacks/#{model_clazz}_callbacks"
#   callback_class = callback_clazz.classify.pluralize.constantize
#   model_class.send(:include, callback_class)
# end
