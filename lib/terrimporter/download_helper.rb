module DownloadHelper
  def create_dir_path(dir)
    unless File.directory?(dir) and File.file?(dir)
      LOG.debug "Creating directory: #{dir}"
      FileUtils.mkpath(dir)
    end
  end
end