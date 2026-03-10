class ConvertModelToCsv < ApplicationService
  def call(model, fields)
    CSV.generate do |csv|
      csv << fields
      model.all.each do |entry|
        csv << fields.map { |field| entry.send(field) }
      end
    end
  end
end
