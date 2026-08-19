# frozen_string_literal: true

# 自动同步 assets(增量模式):每次 jekyll 构建(serve / build / watch 重建)时,
# 将 _posts 下所有名为 assets 的目录拷贝到仓库根目录(去掉 _posts 前缀)。
#
# 例如: _posts\学习\阅读\2021\xxx\assets  ->  学习\阅读\2021\xxx\assets
#
# 增量模式:只把源目录里【新增或更新】的文件/子目录拷贝/覆盖过去,
# 不删除目标目录中已有的文件(与 copy-assets.ps1 的"先删后复制"不同)。
# 因此:
#   - 源里新加的图片会被自动拷贝进来 ✓
#   - 目标目录里手动添加、但源里没有的文件会被保留 ✓
#   - 源里删除的文件不会从目标中移除(可能残留,这是增量模式的取舍)
#
# 注意:GitHub Pages 线上构建不会加载本地 _plugins,
# 因此请把同步后的文件(jekyll s 一次后即已生成)一并 git commit。

require "fileutils"

# 增量递归拷贝:把 src 的内容合并进 dest(已存在的保留,重复的覆盖,子目录递归)
copy_incremental = lambda do |src, dest|
  FileUtils.mkdir_p(dest)
  Dir.glob(File.join(src, "*"), File::FNM_DOTMATCH).each do |item|
    base = File.basename(item)
    # Windows 上 FNM_DOTMATCH 会把 "." 和 ".." 也匹配进来,必须跳过,否则会无限递归
    next if base == "." || base == ".."
    target = File.join(dest, base)

    if File.directory?(item)
      # 目标同名位置是文件时先移除,保证目录结构正确
      FileUtils.rm_f(target) if File.file?(target)
      copy_incremental.call(item, target)
    else
      # 内容相同则跳过拷贝。
      # 若不管内容一律 cp,会更新目标 mtime,触发 watch 检测到变化并重建,
      # 重建又触发 cp……形成无限循环,还会把 listen 的监听线程拖崩。
      next if File.exist?(target) && FileUtils.compare_file(item, target)
      FileUtils.cp(item, target)
    end
  end
end

Jekyll::Hooks.register :site, :after_reset do |site|
  src_base = File.join(site.source, "_posts")
  next unless File.directory?(src_base)

  # 递归查找 _posts 下所有名为 assets 的目录
  assets_dirs = Dir.glob(File.join(src_base, "**", "assets")).select do |p|
    File.directory?(p)
  end

  assets_dirs.each do |dir|
    # 计算相对路径,例如 学习/阅读/2021/xxx/assets
    rel  = dir.sub(/\A#{Regexp.escape(src_base)}[\\\/]+/, "")
    dest = File.join(site.source, rel)

    copy_incremental.call(dir, dest)

    Jekyll.logger.info "copy-assets:", rel
  end

  Jekyll.logger.info "copy-assets:", "Synced #{assets_dirs.length} assets director#{assets_dirs.length == 1 ? 'y' : 'ies'}." unless assets_dirs.empty?
end
