require 'machinist/active_record'

User.blueprint do
  login { "Tom#{sn}" }
  email { "tom#{sn}@email.com" }
  key   { "0123456789012340#{sn}" }
  secret{ "aaaaabbbbbcccccddddd111112222233333I#{sn}" }
end

Domain.blueprint do
  user
  name { "bookmark_#{sn}" }
end

Item.blueprint do
  domain
  name { "item_#{sn}" }
end

Attr.blueprint do
  item
  name { "attr_#{sn}" }
  content { "v_#{sn}" }
end
