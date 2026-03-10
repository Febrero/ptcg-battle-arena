class LoadPlayersFromCsv < ApplicationService
  DROPS = ActiveSupport::HashWithIndifferentAccess.new({
    FE: "First Edition Drop",
    "#2": "Drop #2",
    "#3": "Drop #3",
    "#4": "Drop #4",
    "#5": "Drop #5",
    "#6": "Drop #6",
    "#Y1": "Yankar #1",
    "#Y2": "Yankar #2",
    "#Y3": "Yankar #3"
  }).freeze

  # Creates all klass players with the new properties
  def call(file_path, klass, update_db = nil)
    klass.destroy_all if update_db
    table = CSV.parse(File.read(file_path), headers: true)
    arr = []
    table.each do |row|
      data = {
        uid: row[0].to_i,
        rarity: row[1],
        player_name: row[3],
        drop: DROPS[row[4]],
        drop_slug: row[4],
        position: row[5],
        defense: row[6].to_i,
        attack: row[7].to_i,
        stamina: row[8].to_i,
        ball_stopper: row[9].to_s == "X",
        super_sub: row[10].to_s == "X",
        inspire: row[11].to_s,
        captain: row[12].to_s,
        man_mark: row[13].to_i,
        long_passer: row[14].to_s == "X",
        enforcer: row[15].to_s == "X",
        box_to_box: row[16].to_s == "X",
        dribbler: row[17].to_s == "X",
        power: row[18].to_i
      }
      arr << data
      klass.create(data) if update_db
    end
    arr
  end
end
