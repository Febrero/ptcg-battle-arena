FactoryBot.define do
  factory :ticket_balance, class: "TicketBalance" do
    wallet_addr { "0x1231231231231231231231231231231231231231" }
    balance { rand(1000) }
    deposited { rand(1000) }
  end
end
