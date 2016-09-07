require 'date'
require 'digest'
require 'aws-sdk'

class Uploader
  LAST_DEPLOY_PATH = 'data/last_deploy.json'
  DIST_PATH = 'data/dist'

  def run
    shas = get_shas
    Dir.chdir DIST_PATH do
      Dir.glob("api/**/*.*").each do |file|
        sha256 = Digest::SHA256.file(file).hexdigest
        next if shas[file] && shas[file] == sha256
        shas[file] = sha256
        puts "Deploying #{file}"
        upload_file(bucket, file)
      end
    end
    File.open(LAST_DEPLOY_PATH,"w") do |f|
      f.write(shas.to_json)
    end
  end

  def bucket
    return @bucket if @bucket
    bucket_name = 'kortapositioner.se'
    s3 = Aws::S3::Resource.new(region:'eu-west-1')
    @bucket = s3.bucket(bucket_name)
  end

  private

  def get_shas
    return {} unless File.file?(LAST_DEPLOY_PATH)
    shas = JSON.parse(File.read(LAST_DEPLOY_PATH))
  end

  def content_type(file_path)
    return 'applicaton/json' if file_path.end_with?('.json')
    return 'applicaton/x-javascript' if file_path.end_with?('.js')
    return 'text/html' if file_path.end_with?('.html')
  end

  def upload_file(bucket, file_path)
    bucket.object(file_path).upload_file(file_path, {content_type: content_type(file_path)})
  end
end
