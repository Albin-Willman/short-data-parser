require 'googlecharts'
class ChartGenerator
  def self.build_company_chart(company)
    data, legends = [], []
    company[:positions].each do |key, p|
      legends << p[:name]
      data << p[:positions].values.map { |v| v*100 }
    end
    chart = Gchart.new( type: 'line',
                    title: company[:name],
                    theme: :pastel,
                    data: data,
                    legend: legends,
                    axis_with_labels: ['Date', '%'],
                    size: '600x300',
                    filename: 'tmp/chart.png')

    # Record file in filesystem
    "#{Rails.root.to_s}/tmp/chart.png"
  end
end