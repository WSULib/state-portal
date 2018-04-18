module FileHelper

  def is_image?(file)
    %w{.jpg .png .jpg .gif .bmp}.include?(File.extname(file))
  end

  def file_extension(file)
    File.extname(file).delete('.')
  end

end
