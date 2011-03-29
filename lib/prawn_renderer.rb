require 'prawn'
require 'prawn/measurement_extensions'
require 'prawn/table'

module PrawnRenderer
  class DocumentWrapper
    def initialize(view, template)
      @view = view
      @template = template
      @pdf = Prawn::Document.new
    end

    def method_missing(symbol, *args, &block)
      if @pdf.respond_to?(symbol)
	@pdf.send(symbol, *args, &block)
      elsif @view.respond_to?(symbol)
	@view.send(symbol, *args, &block)
      else
	super
      end
    end

    def pos_y
      @pdf.y
    end

    def render
      for instance_variable_name in @view.instance_variables
	instance_variable_sym = instance_variable_name.to_sym
	unless instance_variable_defined?(instance_variable_sym)
	  instance_variable_set(instance_variable_sym, @view.instance_variable_get(instance_variable_sym))
	end
      end
      eval(@template.source)
      @pdf.render
    end
  end

  class TemplateHandler < ActionView::TemplateHandler
    include ActionView::TemplateHandlers::Compilable
    def compile(template)
      code = <<-EOS
	doc = PrawnRenderer::DocumentWrapper.new(self, template)
	doc.render
      EOS
    end
  end
end
Mime::Type.register("application/pdf", :pdf)
ActionView::Template::register_template_handler(:prawn, PrawnRenderer::TemplateHandler)
