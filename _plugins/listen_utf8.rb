# frozen_string_literal: true

# 修复 Windows 中文路径下 `jekyll serve --watch` 的监听线程崩溃。
#
# 现象: 终端出现
#   Encoding::CompatibilityError: incompatible character encodings: UTF-8 and GBK
#   位于 pathname.rb `join` / listen directory.rb `_children`
# 之后 watch 不再响应文件变化。
#
# 原因: 中文 Windows 上 Dir.foreach 枚举出的目录项被标记为 filesystem 编码(GBK),
# 字节也是 GBK;listen 用 UTF-8 的 Pathname 去 join 这些项时编码不兼容即抛错。
# 此补丁让 Pathname#children 在遇到编码冲突时,把目录项从 GBK 转码为 UTF-8 后重试,
# 与 Jekyll 生成的文件名编码保持一致。
# 只影响本地 serve;GitHub Pages 不加载本地 _plugins,线上行为不受影响。

require "pathname"

class Pathname
  alias_method :children_without_utf8_fix, :children

  def children(with_directory = true)
    children_without_utf8_fix(with_directory)
  rescue Encoding::CompatibilityError
    result = []
    Dir.foreach(@path) do |entry|
      next if entry == "." || entry == ".."
      # 真正的转码:GBK 字节 -> UTF-8 字节(仅 force_encoding 会导致 invalid byte sequence)
      entry = entry.encode(Encoding::UTF_8)
      result << (with_directory ? self + entry : Pathname.new(entry))
    end
    result
  end
end
