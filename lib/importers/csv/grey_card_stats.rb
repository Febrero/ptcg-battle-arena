module Importers
  module Csv
    class GreyCardStats < Base
      HEADERS = [
        :videoposition, :rarity, :cards, :player, :drop, :position, :defense,
        :attack, :stamina, :ball_stopper, :super_sub, :inspire, :captain,
        :man_mark, :long_passer, :enforcer, :box_to_box, :dribbler, :power
      ]

      DROPS = ActiveSupport::HashWithIndifferentAccess.new({
        FE: "First Edition Drop",
        "#2": "Drop #2",
        "#3": "Drop #3",
        "#4": "Drop #4",
        "#5": "Drop #5",
        "#6": "Drop #6",
        "#7": "Drop #7",
        "#Y1": "Yankar #1",
        "#Y2": "Yankar #2",
        "#Y3": "Yankar #3"
      }).freeze

      protected

      def import_line(line)
        GreyCard.where(uid: line.uid).first_or_initialize.update(
          rarity: line.rarity,
          player_name: line.player_name,
          drop: line.drop,
          drop_slug: line.drop_slug,
          position: line.position,
          defense: line.defense,
          attack: line.attack,
          stamina: line.stamina,
          ball_stopper: line.ball_stopper,
          super_sub: line.super_sub,
          inspire: line.inspire,
          captain: line.captain,
          man_mark: line.man_mark,
          long_passer: line.long_passer,
          enforcer: line.enforcer,
          box_to_box: line.box_to_box,
          dribbler: line.dribbler,
          power: line.power
        )
      end

      def after_import
        Deck.batch_size(50).each do |deck|
          deck.save
        end

        SampleDeck.batch_size(50).each do |deck|
          deck.save
        end
      end

      def validate_line!(line)
        errors = []

        if line[:player_name].nil?
          errors << "Invalid player name!"
        end

        if DROPS[line[:drop]].nil?
          errors << "Drop missing on importer!"
        end

        if line[:drop_slug].nil?
          errors << "Invalid drop!"
        end

        if line[:rarity].nil?
          errors << "Invalid rarity!"
        end

        if !["Defender", "Forward", "Goalkeeper", "Midfielder", "Winger"].include?(line[:position])
          errors << "Invalid position!"
        end

        if !is_num?(line[:videoposition])
          errors << "Invalid videoposition value!"
        end

        if !is_num?(line[:defense])
          errors << "Invalid defense value!"
        end

        if !is_num?(line[:attack])
          errors << "Invalid attack value!"
        end

        if !is_num?(line[:stamina])
          errors << "Invalid stamina value!"
        end

        if line[:ball_stopper] == "X"
          errors << "Invalid ball_stopper value!"
        end

        if line[:super_sub] == "X"
          errors << "Invalid ball_stopper value!"
        end

        if !["A1", "A2", "A3", "L1", "L2", "L3", "S1", "S2", "S3"].include?(line[:inpire])
          errors << "Invalid inspire value!"
        end

        if !["A1", "A2", "A3", "L1", "L2", "L3", "S1", "S2", "S3"].include?(line[:captain])
          errors << "Invalid captain value!"
        end

        if !is_num?(line[:man_mark])
          errors << "Invalid man_mark value!"
        end

        if line[:long_passer] == "X"
          errors << "Invalid long_passer value!"
        end

        if line[:enforcer] == "X"
          errors << "Invalid enforcer value!"
        end

        if line[:box_to_box] == "X"
          errors << "Invalid box_to_box value!"
        end

        if line[:dribbler] == "X"
          errors << "Invalid dribbler value!"
        end

        if !is_num?(line[:power])
          errors << "Invalid power value!"
        end
      end

      def validate_headers!
        if HEADERS.map(&:to_sym).sort != csv_table.headers.map(&:to_sym).sort
          raise "Invalid headers! Expected: #{HEADERS.join(",")}"
        end
      end

      def objectify_line(line)
        line_data = {
          uid: line[:videoposition],
          player_name: line[:player],
          drop: DROPS[line[:drop]],
          drop_slug: line[:drop],
          rarity: line[:rarity],
          position: line[:position],
          defense: line[:defense].to_i,
          attack: line[:attack].to_i,
          stamina: line[:stamina].to_i,
          ball_stopper: line[:ball_stopper] == "X",
          super_sub: line[:super_sub] == "X",
          inspire: line[:inspire],
          captain: line[:captain],
          man_mark: line[:man_mark].to_i,
          long_passer: line[:long_passer] == "X",
          enforcer: line[:enforcer] == "X",
          box_to_box: line[:box_to_box] == "X",
          dribbler: line[:dribbler] == "X",
          power: line[:power].to_i
        }

        OpenStruct.new(line_data)
      end

      def is_num?(str)
        !!Integer(str)
      rescue ArgumentError, TypeError
        false
      end
    end
  end
end
