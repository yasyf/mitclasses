class ReactComponentMount < React::Rails::ComponentMount
  def react_component(name, props = {}, options = {}, &block)
    props.keys.each do |k|
      props[k] = props[k].as_json(react: true) if props[k].respond_to?(:as_json)
    end
    super
  end
end
