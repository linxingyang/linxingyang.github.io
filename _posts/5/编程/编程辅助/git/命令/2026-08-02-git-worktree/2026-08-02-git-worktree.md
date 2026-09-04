---
layout: post
published: true
toc: true
title: git-worktree
description:
date: 2026-08-10T11:22:04.157Z
tags:
  - 编程/编程辅助/git
editor: markdown
dateCreated:
location:
---
# 一、什么是 Git Worktree？

**一句话：一个仓库，多个工作目录，每个目录检出不同分支，互不干扰。**

- 传统方式：一个仓库只能有一个工作目录，切换分支 = 替换整个工作目录的文件
- Git Worktree：一个仓库可以挂多个工作目录，每个目录对应不同分支，同时存在

> **每个 worktree 就是独立的 Git 工作环境，在里面 pull、merge、rebase，效果和在那个目录下单独 `git clone` 了一份仓库一模一样。**
> 
> 唯一的区别是：它们共享 `.git/objects/`，所以不用重复下载，更省磁盘空间。

## 和之前的"副本"方式对比

我原先的工作方式是
- git clone project_a
- checkout到对应分支
- 复制（除了.git目录外）到 project_a_copy
- 在project_a_copy中开发
- 开发完成后，使用beyondcompare从project_a_copy同步需要提交的内容到project_a
这种方式有两个好处
- 绝对不会提交任何不在自己预料之内的文件/代码，比如本地调试时临时写的日志，不在.gitignore中限制的新文件。
- 通过beyondcompare对比的方式，逼着自己再走读一遍要提交的代码。

|            | 之前的 `project_a_copy` | `git worktree`        |
| ---------- | -------------------- | --------------------- |
| 目录关系       | 手动复制，彼此独立            | Git 原生管理，共享同一个 `.git` |
| 提交历史       | 各自独立，需要手动同步          | **共享同一份历史**，提交立即可见    |
| IDE Git 功能 | ❌ 副本中没有              | ✅ 每个目录都有完整的 Git 功能    |
| 同步修改       | 靠 BeyondCompare      | **不需要同步**，Git 自动管理    |
| 磁盘占用       | 完整复制（含 .git）         | 只复制工作文件，.git 共享       |

这两种方式都可以使用，多一个方式多一种选择。
如果代码文件不是很多，倾向于小步迭代提交，那么使用git worktree方式更合适。
如果是初步接触代码，本地代码可能会添加很多调试代码，可以使用copy的方式。


---

# 二、Git Worktree 核心原理

```
project_a/                          ← 主工作树（main 分支）
├── .git/                           ← 唯一的 Git 仓库（所有历史、分支、对象都在这里）
│   └── worktrees/                  ← 记录链接工作树的信息
│       ├── feature-login/
│       └── bugfix-123/
├── src/
├── main.c
└── ...

project_a_feature-login/            ← 链接工作树（feature-login 分支）
├── .git                            ← 不是目录！是一个文件，指向主仓库的 .git
├── src/
├── main.c
└── ...

project_a_bugfix-123/              ← 链接工作树（bugfix-123 分支）
├── .git                            ← 同上，指向主仓库
├── src/
├── main.c
└── ...
```

**关键点：**
- 主工作树就是 `git clone` 下来的原始目录
- 链接工作树里的 `.git` 是一个**文件**（不是目录），内容指向主仓库
- 所有工作树**共享同一个 Git 对象库**，所以提交记录、分支、远程配置都是共享的
- 每个工作树有**独立的索引（暂存区）和工作区**，互不干扰

---

# 三、完整命令手册

|子命令|说明|
|---|---|
|`git worktree add`|创建新的工作树|
|`git worktree list`|列出所有工作树|
|`git worktree remove`|删除工作树|
|`git worktree move`|移动工作树到新位置|
|`git worktree lock/unlock`|锁定/解锁工作树（防止被误删）|
|`git worktree prune`|清理过期的 worktree 元数据|
|`git worktree repair`|修复损坏的 worktree 连接|

## 3.1 创建工作树

```bash
# 基础用法：为已有分支创建工作树
git worktree add ../project_a_feature-login feature-login

# 创建工作树的同时创建新分支
git worktree add -b feature-new ../project_a_feature-new main
#                       ↑ 新分支名          ↑ 目录路径        ↑ 基于哪个分支创建

# 创建基于某个提交的临时工作树（分离 HEAD 模式）
git worktree add --detach ../project_a_temp abc1234
```

**路径建议：** 放在主仓库的**同级目录**，命名用 `项目名_分支名`，方便识别：

```
workspace/
├── project_a/                    ← 主工作树
├── project_a_feature-login/      ← 链接工作树
├── project_a_bugfix-123/         ← 链接工作树
└── project_a_hotfix-urgent/      ← 链接工作树
```

## 3.2 查看所有工作树

```bash
git worktree list

# 输出：
# /home/user/workspace/project_a                  abc1234 [main]
# /home/user/workspace/project_a_feature-login    def5678 [feature-login]
# /home/user/workspace/project_a_bugfix-123       ghi9012 [bugfix-123]

# 详细查看（带状态标注）
git worktree list -v
```

## 3.3 在工作树中工作

```bash
# 直接 cd 进去，和正常 Git 操作完全一样
cd ../project_a_feature-login

# 查看当前分支
git branch
# * feature-login    ← 自动检出

# 正常开发、提交、推送
git add .
git commit -m "feat: 完成登录功能"
git push

# 在另一个终端，主工作树里也能立刻看到这个提交
cd ../project_a
git log --oneline -1
# def5678 feat: 完成登录功能    ← 已经可见！
```

## 3.4 删除工作树

```bash
# 方式一：正常删除（推荐）
git worktree remove ../project_a_feature-login

# 如果工作树里有未提交的修改，会拒绝删除，加 --force 强制删除
git worktree remove --force ../project_a_feature-login

# 方式二：手动删除目录后，清理残留记录
rm -rf ../project_a_feature-login
git worktree prune          # 清理已失效的元数据
```

## 3.5 锁定工作树

```bash
# 防止工作树被误删或被自动清理（比如你暂时不用但想保留）
git worktree lock ../project_a_feature-login

# 解锁
git worktree unlock ../project_a_feature-login

# 加备注说明为什么锁定
git worktree lock --reason "等测试确认后才能删除" ../project_a_feature-login
```

## 3.6 移动工作树

```bash
git worktree move ../project_a_feature-login ../new_location/project_a_feature-login
```

## 3.7 修复工作树

```bash
# 如果工作树连接出了问题（比如手动移动了目录）
git worktree repair
```

---

# 四、完整工作流演示

### 场景：正在开发 feature-login，突然要修紧急 BUG

```bash
# ========== 第一步：初始状态 ==========
git clone https://github.com/xxx/project_a.git
cd project_a
git checkout -b feature-login

# 正在开发中...改了十几个文件，还没提交
# 突然接到紧急 BUG 修复任务！

# ========== 第二步：创建 BUG 修复工作树 ==========
# 不需要 stash，不需要提交半成品，直接创建新工作树
git worktree add -b hotfix-urgent ../project_a_hotfix-urgent main

# ========== 第三步：在 BUG 工作树中修复 ==========
cd ../project_a_hotfix-urgent

# 修复 BUG...
git add .
git commit -m "fix: 修复线上紧急BUG"
git push

# 验证修复无误后，清理工作树
cd ../project_a
git worktree remove ../project_a_hotfix-urgent

# ========== 第四步：继续开发 feature-login ==========
# 什么都不用做！工作区还是你之前改动的样子
git status
# 十几个文件的修改还在，继续开发
```

## 也可以同时开多个工作树并行开发

```bash
git worktree add -b feature-login ../project_a_feature-login main
git worktree add -b feature-export ../project_a_feature-export main
git worktree add -b feature-refactor ../project_a_feature-refactor main

git worktree list
# /home/user/workspace/project_a                  abc1234 [main]
# /home/user/workspace/project_a_feature-login    def5678 [feature-login]
# /home/user/workspace/project_a_feature-export   def5678 [feature-export]
# /home/user/workspace/project_a_feature-refactor  def5678 [feature-refactor]

# 用 IDE 分别打开不同目录，各自开发，互不干扰
```

---

# 五、重要限制和注意事项

##  限制一：同一个分支不能同时被两个工作树检出

```bash
# main 已经在主工作树中检出了
git worktree add ../project_a_copy main

# ❌ 报错：
# fatal: 'main' is already checked out at '/home/user/workspace/project_a'
```

**原因：** 如果两个工作树同时修改同一个分支，Git 无法决定以哪个为准。
**解决：** 如果确实需要在另一个目录看 main 的代码，用 `--detach`：

```bash
git worktree add --detach ../project_a_main_copy main
# 只读查看，不绑定分支
```

## 限制二：删除工作树前要先移除或合并分支

链接工作树中创建的分支，在删除工作树后仍然存在，但可能变成"孤儿"。

## 限制三：IDE 的缓存/配置可能冲突

如果你用 VS Code / CLion 等同时打开多个工作树，它们的 `.vscode/`、`.idea/` 等目录是独立的，不会冲突。但要注意：

- **全局缓存**（如 Xcode 的 DerivedData、CMake 的全局缓存）可能指向同一位置，需要配置为各自独立
- **node_modules** 等依赖目录各自独立，需要分别 `npm install`

## 限制四：工作树内的 .git 是文件不是目录

```bash
# 链接工作树中
cat project_a_feature-login/.git
# gitdir: /home/user/workspace/project_a/.git/worktrees/feature-login
```

所以**不要手动删除主工作树中的 `.git/worktrees/` 目录**，否则链接工作树会失效。

---

# 六、VS Code / Cursor 对 Worktree 的支持

**VS Code 原生支持！** 你可以直接用 VS Code 打开不同的工作树目录，每个窗口都有完整的 Git 功能。

VS Code 2026 年还新增了**内置 Git Worktree 管理面板**：

```
1. Ctrl+Shift+P → 输入 "Git: Worktree"
2. 可以在 VS Code 内直接创建、删除、切换工作树
3. 每个工作树是一个独立的 VS Code 窗口
```

---

# 七、和你旧习惯的映射关系

```
你以前的方式                        Git Worktree 方式
─────────────────────────────        ─────────────────────────────
project_a/         (原始仓库)    →   project_a/         (主工作树)
project_a_copy/    (手动复制的)   →   project_a_login/   (链接工作树)
BeyondCompare 同步               →   不需要同步！Git 自动管理
手动排除 .o/Debug/Release        →   .gitignore 自动过滤
副本中无法用 Git 功能            →   每个工作树都有完整 Git 功能
```

---

# 八、推荐的Git Worktree工作习惯

```
日常工作流：
1. git clone → 主工作树保持 main 分支
2. 每个新任务：git worktree add -b 分支名 ../目录名 main
3. IDE 打开对应的工作树目录开发
4. 开发完成 → 提交推送 → git worktree remove
5. 主工作树随时保持干净，用于创建新的工作树

常用目录结构：
workspace/
├── project_a/                     ← 主工作树 (main，保持干净)
├── project_a_feature-login/       ← 临时工作树
├── project_a_bugfix-123/          ← 临时工作树
└── 用完就删，需要时再建
```

> **核心思想：主工作树是你的"总台"，链接工作树是你的"作战室"，用完即弃，随时创建。**

# 参考

- https://git-scm.com/docs/git-worktree/zh_HANS-CN

