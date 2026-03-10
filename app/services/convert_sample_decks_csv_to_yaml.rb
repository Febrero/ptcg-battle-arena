class ConvertSampleDecksCsvToYaml < ApplicationService
  def call file_path
    table = CSV.parse(File.read(file_path), headers: false)
    rarity_data = table.select { |row| row[0]&.match(/^[[:alpha:]]$/) }
    positions_data = table.select { |row| row[0]&.match(/^[-+]?\d+$/) }
    hash = []

    i = 0
    rarity_data.each do |alpha_row|
      positions_data.each do |number_row|
        hash[i] = {
          type: alpha_row[0] + number_row[0],
          rarities: {
            Grey: alpha_row[1].to_i,
            Common: alpha_row[2].to_i,
            Special: alpha_row[3].to_i,
            Epic: alpha_row[4].to_i,
            Legendary: alpha_row[5].to_i,
            Unique: alpha_row[6].to_i
          },
          positions: {
            Goalkeeper: number_row[1].to_i,
            Defender: number_row[2].to_i,
            Midfielder: number_row[3].to_i,
            Forward: number_row[4].to_i
          }
        }
        i += 1
      end
    end

    File.write(file_path.sub!("imports", "config").sub!("csv", "yaml"), hash.to_yaml)
  end
end
