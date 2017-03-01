require 'googlecharts'
class ChartGenerator
  CHART_NAME = 'tmp/chart.png'
  def self.build_company_chart(name, data)

    chart = Gchart.new( type: 'line',
                    title: name,
                    theme: :pastel,
                    data: data,
                    axis_with_labels: ['y'],
                    filename: "tmp/chart.png")

    chart.file
    # Record file in filesystem
    "#{Rails.root.to_s}/#{CHART_NAME}"
  end
end