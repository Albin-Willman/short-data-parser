class StockIndexBuilder
  def run
    {
      companies: Company.all.includes(:blog_posts).inject({}) { |hash ,c| build_company_data(hash, c) },
      lastChange: Date.today.to_s
    }
  end

  def build_company_data(hash, company)
    hash[company.key] = {
      name: company.name,
      total: company.total,
      lastChange: company.last_change,
      change30Days: company.change_30_days
    }
    hash[company.key][:blogPosts] = company.blog_posts.map { |bp| { title: bp.title, path: bp.path }} if company.blog_posts.any?
    hash
  end
end
