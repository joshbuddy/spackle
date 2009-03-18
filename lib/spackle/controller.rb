module Spackle
  
  module Controller
    def self.included(mod)
      puts "including into #{mod}"
    
      mod.class_eval(<<-HERE_DOC, __FILE__, __LINE__)
        @@esi_paths = {}
      
        mattr_reader :esi_paths
        
        def self.esi(method_name, opts={}, &blk)
          @@esi_paths[method_name] = opts
          @@esi_paths[method_name][:controller] = controller_name
          method = Proc.new do
            path_parts = opts[:path].split('/').select{|p| not p.blank?}
            variable_indexes = []
            path_parts.each_with_index{|p, i| p[0] == ?$ and variable_indexes << i}
            extras = params[:extras]
            esi_params = {}
            p extras
            opts[:binds].each {|bind_name| params[bind_name] = params[:extras][variable_indexes.shift]}

            path_parts.each_with_index{|p, i| p[0] == ?: and params[p[1, p.size - 1].to_sym] = params[:extras][i]}

            self.send((method_name.to_s+"_body").to_sym)
          end

          define_method(method_name, &method)
          define_method((method_name.to_s+"_body").to_sym, &blk)

        end
      
      HERE_DOC
    end
  end
  
end