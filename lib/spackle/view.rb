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

    def esi_try(*args, &blk)
      esi_tag('try', *args, &blk)
    end
    
    def esi_attempt(*args, &blk)
      esi_tag('attempt', *args, &blk)
    end
    
    def esi_except(*args, &blk)
      esi_tag('except', *args, &blk)
    end
    
    def esi_include(name, *args)
      path_parts = ActionController::Base.esi_paths[name][:path].split('/').select{|p| not p.blank?}
      path_parts.collect! do |p|
        if p[0] == ?:
          case args.last 
          when Hash
            args.last.delete(p[1,p.size-1].to_sym)
          else
            args.shift
          end or raise "the variable #{p} references by your esi method needs to be given a value"
        else
          p
        end
      end
      %{<esi:include src="#{spackle_esi_url(:controller => ActionController::Base.esi_paths[name][:controller], :action => name) + '/'+ path_parts * '/'}"/>}
    end
    
  end
  
end