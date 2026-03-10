FactoryBot.define do
  factory :event_transaction, class: "EventTransaction" do
    tx_hash { "0x1231231231231231231231231231231231231231" }
    log_index { rand(0..100) }
    tx_index { rand(0..100) }
    block_number { rand(0..1000000000) }
    reverted { false }
  end

  trait :sale_created do
    name { "SaleCreated" }
  end

  trait :sale_done do
    name { "SaleDone" }
  end

  trait :sale_canceled do
    name { "SaleCanceled" }
  end

  trait :pack_opened do
    name { "PackOpened" }
  end

  trait :transfer do
    name { "Transfer" }
  end

  trait :buy_ticket do
    name { "BuyTicket" }
  end

  trait :transfer_single do
    name { "TransferSingle" }
  end

  trait :transfer_batch do
    name { "TransferBatch" }
  end

  trait :locked do
    name { "Locked" }
  end
end
