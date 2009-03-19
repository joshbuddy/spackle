module Spackle
  
  module View
    
    def esi_tag(tag, *args, &blk)
      
      if blk
        concat("<esi:#{tag}>")
        blk.call
        concat("</esi:#{tag}>")
      elsif not args.size.zero?
        "<esi:#{tag}>#{esi_include(*args)}</esi:#{tag}>"
      else
        raise "needs to take a block or an include"
      end
    end

    def esi_vars
      concat("<esi:vars>")
      yield
      concat("</esi:vars>")
    end

    def esi_remove
      concat("<esi:remove>")
      yield
      concat("</esi:remove>")
    end

    def esi_comment
      concat("<!--esi")
      yield
      concat("-->")
    end

    def esi_choose
      concat("<esi:choose>")
      yield
      concat("</esi:choose>")
    end

    def esi_try(*args, &blk)
      esi_tag('try', *args, &blk)
    end
    
    def esi_attempt(*args, &blk)
      esi_tag('attempt', *args, &blk)
    end
    
    def esi_except(*args, &blk)
      esi_tag('except', *args, &blk)
    end
    
    def esi_url(name, *args)
      case name 
      when String
        name
      when Symbol
        opts = args.last.is_a?(Hash) ? args.last : nil
        onerror = opts && opts.delete(:onerror) || 'continue'
        
        path_parts = ActionController::Base.esi_paths[name][:path].split('/').select{|p| not p.blank?}
        path_parts.collect! do |p|
          if p[0] == ?:
            if opts
              opts.delete(p[1, p.size - 1].to_sym)
            else
              args.shift
            end or raise "the variable #{p} references by your esi method needs to be given a value"
          else
            p
          end
        end
        
        spackle_esi_url(:controller => ActionController::Base.esi_paths[name][:controller], :action => name) + '/' + (path_parts * '/')
      else
        raise
      end
    end
    
    def esi_src(name, *args)
      %|src="#{esi_url(name, *args)}" |
    end
    
    def esi_alt(name, *args)
      %|alt="#{esi_url(name, *args)}" |
    end
    
    def esi_include(*args)
      if block_given?
        concat("<esi:include ")
        yield
        concat(" />")
      elsif args.first
        %|<esi:include #{esi_src(args.first, *args[1, args.size - 1])}/>|
      else
        raise "include needs name or block"
      end
    end
    
  end
  
end