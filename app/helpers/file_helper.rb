module FileHelper

  def is_image?(file)
    Spotlight::Engine.config.allowed_image_extensions.include?(file_extension(file))
  end

  def file_extension(file)
    File.extname(file).delete('.')
  end

end
