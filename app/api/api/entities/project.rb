class API::Entities::Project < Grape::Entity
  expose :id
  expose :name
  expose :customer_id
end

