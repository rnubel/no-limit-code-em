# Include into API controllers to render correct error responses easily.
module ApiErrors
  def render_bad_request(error)
    render_error error, :bad_request
  end

  def render_not_found(error)
    render_error error, :not_found
  end

  def render_unprocessable_entity(error)
    render_error error, :unprocessable_entity
  end

  def render_unauthorized(error)
    render_error error, :unauthorized
  end

  def render_internal_error(error)
    render_error error, :internal_server_error
  end

  def render_error(error, status_code)
    ActiveRecord::Base.logger.info { "Errors returned to client: #{error.inspect}" }
    render :json => { :error => error }, :status => status_code
  end
end
