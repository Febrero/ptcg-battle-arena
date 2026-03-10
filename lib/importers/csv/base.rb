require "csv"

module Importers
  module Csv
    class Base
      attr_reader :csv_table, :errors, :imported_count

      def initialize(file_path)
        @file_path = file_path
        @errors = []
        @imported_count = 0
      end

      def self.import(file_path)
        new(file_path).import
      end

      def import
        @csv_table = ::CSV.read(@file_path, headers: true, header_converters: :symbol)

        validate_headers!

        @csv_table.each_with_index do |row, index|
          begin
            line = objectify_line(row)
            line_errors = validate_line!(line) || []
            if line_errors.empty?
              import_line(line)
              @imported_count += 1
            else
              @errors << "Row #{index + 2}: #{line_errors.join(', ')}"
            end
          rescue => e
            @errors << "Row #{index + 2}: #{e.message}"
            Rails.logger.error("[Importers::Csv] Error on row #{index + 2}: #{e.message}")
          end
        end

        after_import if @errors.empty?

        Rails.logger.info("[Importers::Csv] Import complete. #{@imported_count} records imported. #{@errors.length} errors.")
        self
      end

      def success?
        @errors.empty?
      end

      protected

      # Override in subclass: process a single line object
      def import_line(line)
        raise NotImplementedError, "#{self.class}#import_line must be implemented"
      end

      # Override in subclass: called after all lines processed successfully
      def after_import
      end

      # Override in subclass: return array of error strings, or empty array if valid
      def validate_line!(line)
        []
      end

      # Override in subclass: raise if headers don't match
      def validate_headers!
      end

      # Override in subclass: convert raw CSV row to a structured object
      def objectify_line(row)
        OpenStruct.new(row.to_h)
      end
    end
  end
end
