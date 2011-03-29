require 'prawn'
module PrawnRenderer
  class TemplateHandler < ActionView::TemplateHandler
    include ActionView::TemplateHandlers::Compilable
    def compile(template)
      code = <<-EOS
	pdf = Prawn::Document.new
	for instance_variable_name in instance_variables
	  unless pdf.instance_variable_defined?(instance_variable_name.to_sym)
	    pdf.instance_variable_set(instance_variable_name.to_sym, instance_variable_get(instance_variable_name.to_sym))
	  end
	end
	pdf.instance_eval do
	  #{template.source}
	end
	pdf.render
      EOS
    end
  end
end
Mime::Type.register("application/pdf", :pdf)
ActionView::Template::register_template_handler(:prawn, PrawnRenderer::TemplateHandler)
