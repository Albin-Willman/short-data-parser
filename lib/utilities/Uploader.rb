require 'date'
require 'aws-sdk'

class Uploader
  TMP_PATH = 'tmp/tmp.json'

  def run(data, file_path)
    return unless data
    File.open(TMP_PATH, "w") do |f|
      f.write(data.to_json)
    end
    upload_file(file_path)
    true
  end

  # def run(data, file_path)
  #   return unless data
  #   File.open(file_path, "w") do |f|
  #     f.write(data.to_json)
  #   end
  #   true
  # end

  def bucket
    return @bucket if @bucket
    bucket_name = 'kortapositioner.se'
    s3 = Aws::S3::Resource.new(region:'eu-west-1')
    @bucket = s3.bucket(bucket_name)
  end

  private

  def upload_file(file_path)
    bucket.object(file_path).upload_file(TMP_PATH, {content_type: 'applicaton/json'})
  end
end
