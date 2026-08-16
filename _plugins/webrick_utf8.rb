# frozen_string_literal: true

# 修复 Windows 本地 `jekyll serve` 无法访问含中文 URL 的问题。
#
# 原因：在中文 Windows 上，Ruby 的 Encoding.find("filesystem") 返回 GBK。
# WEBrick 会把 URL 路径 force_encoding 成该编码；当 URL 的 UTF-8 字节序列在
# GBK 中是非法字节对（例如 0x85 后面跟着 0x2D "-"）时，路径会被转换成乱码 /
# 替换符 U+FFFD，导致 File.directory? 找不到目录而返回 404。
#
# 此补丁让 WEBrick 始终按 UTF-8 处理 URL 路径（与 Jekyll 生成的文件名编码一致）。
# 只影响本地 serve；GitHub Pages 不加载本地 _plugins，线上行为不受影响。

require "webrick"

module WEBrick
  module HTTPServlet
    class FileHandler
      private

      # 原实现：req.path_info.dup.force_encoding(Encoding.find("filesystem"))
      def prevent_directory_traversal(req, res)
        path = req.path_info.dup.force_encoding(Encoding::UTF_8)
        if trailing_pathsep?(req.path_info)
          # File.expand_path 会去掉末尾路径分隔符，加一个字符再 chop 掉以保留它。
          expanded = File.expand_path(path + "x")
          expanded.chop!
        else
          expanded = File.expand_path(path)
        end
        expanded.force_encoding(req.path_info.encoding)
        req.path_info = expanded
      end

      # 原实现：str.dup.force_encoding(Encoding.find("filesystem"))
      def set_filesystem_encoding(str)
        str.dup.force_encoding(Encoding::UTF_8)
      end
    end
  end
end
