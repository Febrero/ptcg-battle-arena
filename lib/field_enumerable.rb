# Mongoid doesn't implemet enum like activerecord, so lets make a workaround
# Enumerable info should be set on the subclass via the field_enumerable concern
module FieldEnumerable
  extend ActiveSupport::Concern

  class_methods do
    attr_reader :field_name, :enum_values, :add_prefix, :add_suffix

    # Receives the enum info for the class that calls it and generates all the info (constants, getters,
    # setters) for it
    #
    #
    # @note the field should be set on the caller class
    #
    # @params enum_info [Hash] The hash containing:
    #                            1) a key with the field name nad as values another hash
    #                               mapping the name and values for that enum
    #                            2) [OPTIONAL] a _prefix flag that tells if the constant is prefixed
    #                            3) [OPTIONAL] a _suffix flag that tells if the constant is suffixed
    #
    # @example
    #   field_enum source: { marketplace: 0, battle_arena: 1 }, _prefix: true
    #
    def field_enum enum_info = {}
      @add_prefix = enum_info.delete(:_prefix)
      @add_suffix = enum_info.delete(:_suffix)

      @field_name = enum_info.keys.first

      @enum_values = enum_info.values.first

      generate_constants

      generate_accessors
    end

    # Generates constants for identifying the values for this enum
    #
    # @note Constants can be prefixed ou suffixed by the field_name value
    #
    # @example Given an action buy_pack
    #   BUY_PACK        = 0 (without prefix/suffix)
    #   BUY_PACK_ACTION = 0 (with suffix)
    #   ACTION_BUY_PACK = 0 (with prefix)
    #
    #
    def generate_constants
      @enum_values.each_pair do |enum_desc, enum_code|
        const_name = enum_desc

        const_name = "#{field_name}_#{const_name}" if add_prefix
        const_name = "#{const_name}_#{field_name}" if add_suffix

        const_set const_name.upcase, enum_code
      end

      const_set "#{field_name.upcase}_TYPES", @enum_values.keys
    end

    # Generates accessors for the field that has the enum (in a readable way)
    #
    # @note The getter validates if the value of the instance is the same has the enum getter
    # @note The setter saves the value of the enum on the DB for this instance
    #
    # @example Given an action buy_pack
    #   buy_pack? (valudates if the instance action value is the same as the buy_pack's enum value)
    #   buy_pack! (saves the value of the buy_pack enum on the DB)
    #
    def generate_accessors
      @enum_values.each_pair do |enum_desc, enum_code|
        class_eval {
          enum_field_name = field_name

          define_method "#{enum_desc}?" do
            send(enum_field_name) == enum_code
          end

          define_method "#{enum_desc}!" do
            update!(enum_field_name => enum_code)
          end
        }
      end
    end
  end
end
