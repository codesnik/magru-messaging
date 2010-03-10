class User

  include DataMapper::Resource
  extend ActiveModel::Translation

  property :id, Serial
  property :name, String

end
