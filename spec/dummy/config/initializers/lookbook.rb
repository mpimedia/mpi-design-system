Rails.application.configure do
  engine_preview_path = Rails.root.join("../..", "spec/components/previews").to_s

  config.view_component.previews.paths << engine_preview_path
  config.lookbook.preview_paths = [ engine_preview_path ]
end
