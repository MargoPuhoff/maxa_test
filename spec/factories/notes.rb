FactoryBot.define do
  factory :note do
    title { Faker::Lorem.sentence(word_count: 3) }
    body { Faker::Lorem.paragraph(sentence_count: 2) }
    archived { false }

    trait :archived do
      archived { true }
    end

    trait :with_long_title do
      title { Faker::Lorem.sentence(word_count: 10) }
    end

    trait :with_empty_body do
      body { "" }
    end
  end
end
