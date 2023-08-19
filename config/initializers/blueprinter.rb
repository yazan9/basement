require 'oj'

Blueprinter.configure do |config|
  config.generator = Oj
  config.sort_fields_by = :definition
  config.datetime_format = ->(datetime) { datetime.nil? ? datetime : datetime.strftime("%Y-%m-%dT%H:%M:%S.%LZ") }
end