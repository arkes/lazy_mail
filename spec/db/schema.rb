ActiveRecord::Schema.define(:version => 0) do

  create_table :users, :force => true do |t|
    t.string  :username
    t.string  :email
  end
  
  create_table :clients, :force => true do |t|
    t.string  :username
    t.string  :email
  end
  
  create_table :others, :force => true do |t|
    t.string  :username
    t.string  :test_mail
  end
  
end