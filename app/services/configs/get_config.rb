module Configs
  class GetConfig < ApplicationService
    def call
      {
        decks: {
          power_upper_tiers: [350, 650, 950, 1250],
          stars_config: [
            {
              stars: 1,
              limits: {
                starter: 50,
                common: 50,
                special: 50,
                epic: 0,
                legendary: 0,
                unique: 0
              }
            },
            {
              stars: 2,
              limits: {
                starter: 50,
                common: 50,
                special: 50,
                epic: 50,
                legendary: 0,
                unique: 0
              }
            },
            {
              stars: 3,
              limits: {
                starter: 0,
                common: 50,
                special: 50,
                epic: 50,
                legendary: 50,
                unique: 0
              }
            },
            {
              stars: 4,
              limits: {
                starter: 0,
                common: 50,
                special: 50,
                epic: 50,
                legendary: 50,
                unique: 50
              }
            },
            {
              stars: 5,
              limits: {
                starter: 0,
                common: 50,
                special: 50,
                epic: 50,
                legendary: 50,
                unique: 50
              }
            }
          ],
          stars: [
            {
              stars: 1,
              start: 0,
              end: 350
            },
            {
              stars: 2,
              start: 351,
              end: 650
            },
            {
              stars: 3,
              start: 651,
              end: 950
            },
            {
              stars: 4,
              start: 951,
              end: 1250
            },
            {
              stars: 5,
              start: 1251,
              end: 9999
            }
          ],
          rules: {
            min_cards: 50,
            max_cards: 50,
            min_gks: 3,
            min_dfs: 0,
            min_mfs: 0,
            min_fws: 0,
            max_wallet_decks_count: 20,
            max_repeated_grey_cards: 1,
            max_repeated_nfts: 4
          }
        },
        tutorial_training_offer_config: [
          {
            query: {
              :uid.in => [6, 8, 15, 28, 31, 32, 37, 39, 43, 45, 52, 60, 62, 67, 68, 71, 72, 73, 76, 77, 78, 79, 81, 88, 91, 100, 108, 115, 121, 122, 129, 130, 134, 135, 136, 139, 143, 145, 146, 149, 156, 160, 193, 195, 203, 215, 241, 246, 253, 278]
            },
            count: 50
          }
        ],
        tutorial_friendly_offer_config: [
          {
            query: {
              :uid.in => [11, 34, 40, 47, 105, 112, 125, 127, 128, 132, 138, 151, 209, 230, 239, 249, 260, 271, 272, 286]
            },
            count: 20
          }
        ]
      }
    end
  end
end
