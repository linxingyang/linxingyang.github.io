# frozen_string_literal: true

# 每次 Jekyll 构建完成（build / serve / watch 重建）后，统计 _posts 目录下
# 的 markdown 文章数量并打印，便于快速确认文章总篇数与分布。
#
# 统计口径：递归统计 _posts 下所有 *.md / *.markdown 文件，
# 并按第一层子目录汇总分布（与 Jekyll 的 site.posts 口径可能略有差异，
# 文件系统统计会包含未按日期命名/无 front matter 的 md 文件）。
#
# 编码说明：中文 Windows 上 Dir.pwd 返回的路径被标记为 GBK，导致 Dir.glob
# 返回的路径字符串也是"GBK 字节 + GBK 标记"。直接插值打印会乱码（Ruby 不会
# 自动转码），因此打印目录名前统一 encode 成 UTF-8；在非中文系统上 glob
# 返回 UTF-8，此时 encode 是 no-op，同样安全。

Jekyll::Hooks.register :site, :post_write do |site|
  posts_dir = File.join(site.source, "_posts")
  next unless File.directory?(posts_dir)

  # 兼容不同 Ruby 版本的 glob 写法，分两次统计避免依赖 FNM_EXTGLOB
  files = Dir.glob(File.join(posts_dir, "**", "*.md")) +
          Dir.glob(File.join(posts_dir, "**", "*.markdown"))
  files = files.select { |f| File.file?(f) }.map { |f| File.expand_path(f) }.uniq

  if files.empty?
    Jekyll.logger.info "post-count:", "No markdown post found under _posts."
    next
  end

  total = files.length
  Jekyll.logger.info "post-count:", "#{total} markdown post(s) under _posts."

  # 按第一层子目录汇总分布
  subs = Dir.glob(File.join(posts_dir, "*"))
            .select { |p| File.directory?(p) }
            .sort_by { |p| File.basename(p) }

  subs.each do |sub_path|
    # 路径字符串可能是 GBK 标记，显示前统一转成 UTF-8，避免中文乱码
    sub = File.basename(sub_path).encode(Encoding::UTF_8)
    sub_count = files.count { |f| f.start_with?(File.expand_path(sub_path) + "/") }
    Jekyll.logger.info "post-count:", "  #{sub}: #{sub_count}"
  end
end
