require 'googlecharts'
class ChartGenerator
  CHART_NAME = 'tmp/chart.png'
  def self.build_company_chart(company)
    data, legends = [], []
    company[:positions].each do |key, p|
      legends << p[:name]
      data << p[:positions].values.map { |v| v*100 }
    end
    Gchart.new( type: 'line',
                title: company[:name],
                theme: :pastel,
                data: data,
                legend: legends,
                axis_with_labels: ['Date', '%'],
                size: '600x300',
                filename: CHART_NAME).file

    # Record file in filesystem
    "#{Rails.root.to_s}/#{CHART_NAME}"
  end
end