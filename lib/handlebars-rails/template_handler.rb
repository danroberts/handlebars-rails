module Handlebars
  class TemplateHandler

  def self.handlebars
    @context ||= new_context
  end

  def self.call(template)
    %{
      handler = ::Handlebars::TemplateHandler
      handlebars = handler.handlebars
      handler.with_view(self) do
        handlebars.compile(#{template.source.inspect}).call(local_assigns).force_encoding(Encoding.default_external).html_safe
      end
    }
  end

  def self.with_view(view)
    original_view = data['view']
    data['view'] = view
    yield
  ensure
    data['view'] = original_view
  end

  def self.new_context
    Handlebars::Context.new.tap do |context|
      context['rails'] = {}
      context.partial_missing do |name|
        name = name.gsub('.', '/')
        lookup_context = data['view'].lookup_context
        prefixes = lookup_context.prefixes.dup
        prefixes.push ''
        partial = lookup_context.find(name, prefixes, true)
        lambda do |this, context|
          if partial.handler == self
            handlebars.compile(partial.source).call(context)
          else
            data['view'].render :partial => name, :locals => context
          end
        end
      end
    end
  end

  def self.data
    @context['rails']
  end
end
end