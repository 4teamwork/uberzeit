class API::Shared::Validators::Includes < Grape::Validations::Base
  def validate_param!(attr_name, params)
    if (Array.wrap(params[attr_name]) - @option).any?
      raise Grape::Exceptions::Validation, status: 422, params: [attr_name], message_key: :invalid
    end
  end
end
