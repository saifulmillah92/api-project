# frozen_string_literal: true

class SubdomainTenantMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    subdomain = extract_subdomain(request.host)

    # Set the tenant based on the subdomain
    setup_tenant(request, subdomain)

    @app.call(env)
  end

  private

  def extract_subdomain(host)
    subdomain = host.split(".")
    return unless subdomain.size > 1

    subdomain.first
  end

  def find_tenant_by_subdomain(subdomain)
    return unless subdomain

    Hotel.find_by(subdomain: subdomain)&.schema
  end

  def setup_tenant(request, subdomain)
    tenant = find_tenant_by_subdomain(subdomain)
    request.env["HTTP_X_CURRENT_TENANT"] = tenant
  end
end
