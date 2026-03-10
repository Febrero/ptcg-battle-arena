class BadgeFormatter < SimpleCov::Formatter::BadgeFormatter
  def result_file_path
    File.join(Rails.root.to_s, RESULT_FILE_NAME)
  end
end
