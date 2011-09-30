module TerrImporter
  class DefaultError < StandardError
  end

  class ConfigurationError < StandardError
  end

  class ConfigurationMissingError < StandardError
  end

  class DownloadError < DefaultError
  end
end