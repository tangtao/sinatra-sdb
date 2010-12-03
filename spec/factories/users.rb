FactoryGirl.define do

  factory :user do
    login "Tom"
    email "tom@email.com"
    key "01234567890123456789"
    secret "aaaaabbbbbcccccddddd11111222223333344444"
  end
  
  factory :userx, :class => User do
    login "Jerry"
    email "jerry@email.com"
    key "11111111111111111111"
    secret "11111222223333344444aaaaabbbbbcccccddddd"
  end

  factory :domain do
    name "bookmark"
    association :user, :factory => :userx
  end

end