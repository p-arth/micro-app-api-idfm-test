desc "Clean up all temporary files in the application directory"

task :cleanup do
  puts "Removing temporary stored json contents"
  tmp_files = []
  %w{ storage }.each do |dir|
    tmp_files += Dir.glob( File.join(Rails.root, "tmp", dir, "*") )
  end
  File.delete(*tmp_files)

end