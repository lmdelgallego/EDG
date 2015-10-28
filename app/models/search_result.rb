class SearchResult < ActiveRecord::Base
  belongs_to :searchable, polymorphic: true

  def find_relation(class_name, instance_id)
  	Object.const_get(class_name).find(instance_id)
  end
end
