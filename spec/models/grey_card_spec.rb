require "rails_helper"

RSpec.describe GreyCard, type: :model do
  subject { described_class.new }

  describe "Validations" do
    it { is_expected.to have_index_for(uid: 1).with_options(name: "uid_index", background: true) }
    it { is_expected.to have_index_for(rarity: 1).with_options(name: "rarity_index", background: true) }
    it { is_expected.to have_index_for(position: 1).with_options(name: "position_index", background: true) }
    it { is_expected.to have_index_for(defense: 1).with_options(name: "defense_index", background: true) }
    it { is_expected.to have_index_for(attack: 1).with_options(name: "attack_index", background: true) }
    it { is_expected.to have_index_for(stamina: 1).with_options(name: "stamina_index", background: true) }
    it { is_expected.to have_index_for(ball_stopper: 1).with_options(name: "ball_stopper_index", background: true) }
    it { is_expected.to have_index_for(super_sub: 1).with_options(name: "super_sub_index", background: true) }
    it { is_expected.to have_index_for(man_mark: 1).with_options(name: "man_mark_index", background: true) }
    it { is_expected.to have_index_for(enforcer: 1).with_options(name: "enforcer_index", background: true) }
    it { is_expected.to have_index_for(inspire: 1).with_options(name: "inspire_index", background: true) }
    it { is_expected.to have_index_for(captain: 1).with_options(name: "captain_index", background: true) }
    it { is_expected.to have_index_for(long_passer: 1).with_options(name: "long_passer_index", background: true) }
    it { is_expected.to have_index_for(box_to_box: 1).with_options(name: "box_to_box_index", background: true) }
    it { is_expected.to have_index_for(dribbler: 1).with_options(name: "dribbler_index", background: true) }
    it { is_expected.to have_index_for(updated_at: 1).with_options(name: "updated_at_index", background: true) }
  end
end
