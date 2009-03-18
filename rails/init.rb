class ActionController::Routing::RouteSet

  alias_method :__draw, :draw

  # Overrides the default RouteSet#draw to automatically
  # include the routes needed by the ThemeController
  def draw
    begin 
      clear!
      mapper = Mapper.new(self)
      mapper.spackle_esi "/spackle/:controller/:action/*extras"
      yield mapper
      named_routes.install
    rescue
      raise
    end
  end
  
end

class ::ActionController::Base #:nodoc:
  include Spackle::Controller
end

class ::ActionView::Base
  include Spackle::View
end