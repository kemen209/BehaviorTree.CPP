# 编译BehaviorTree.CPP

## 1. 安装conna编译工具

### 1.1 下载conna编译工具

https://conan.io/downloads

### 1.2 下载源码

git clone https://github.com/kemen209/BehaviorTree.CPP.git

### 1.3 切换到指定版本

# 注意：这个版本将zeromq和sqlite3编译为共享库
```
git checkout v4.7.2
```

## 配置修改

### 1. 修改 conanfile.txt

在项目根目录的 `conanfile.txt` 中添加动态库选项：

```txt
[requires]
gtest/1.14.0
zeromq/4.3.4
sqlite3/3.40.1

[generators]
CMakeDeps
CMakeToolchain

[options]
zeromq/*:shared=True
sqlite3/*:shared=True
```

## Release 版本编译命令

### 步骤 1: 创建构建目录
```bash
mkdir build_release
```

### 步骤 2: 安装依赖
```bash
conan install . -of build_release -s build_type=Release --build=missing -s compiler.cppstd=17
```

**重要说明：**
- `-s compiler.cppstd=17` 设置Host Profile的C++标准为17，这是应用程序的编译标准
- Conan会显示两个Profile：Host Profile（目标平台）和Build Profile（构建工具）
- 主要关注Host Profile中的`compiler.cppstd=17`，这决定了你的代码使用C++17编译
- Build Profile中的C++标准不影响最终应用程序，只影响构建工具

### 步骤 3: 配置 CMake
```bash
cmake -S . -B build_release -DCMAKE_TOOLCHAIN_FILE="build_release/conan_toolchain.cmake"
```

### 步骤 4: 编译项目
```bash
cmake --build build_release --config Release --parallel
```

## Debug 版本编译命令

### 步骤 1: 创建构建目录
```bash
mkdir build_debug
```

### 步骤 2: 安装依赖
```bash
conan install . -of build_debug -s build_type=Debug --build=missing -s compiler.cppstd=17
```

### 步骤 3: 配置 CMake
```bash
cmake -S . -B build_debug -DCMAKE_TOOLCHAIN_FILE="build_debug/conan_toolchain.cmake"
```

### 步骤 4: 编译项目
```bash
cmake --build build_debug --config Debug --parallel
```

## 验证结果

### 检查动态链接依赖
```bash
otool -L build_release/libbehaviortree_cpp.dylib
```

预期输出应包含：
- `@rpath/libzmq.5.dylib` (ZeroMQ 动态库)
- `@rpath/libsqlite3.dylib` (SQLite3 动态库)

### 运行测试示例
```bash
# 基础示例
./build_release/examples/t01_first_tree_static

# SQLite 日志示例
./build_release/examples/ex03_sqlite_log

# Groot2 示例
./build_release/examples/t11_groot_howto
```

## 关键配置说明

### 动态库选项
- `zeromq/*:shared=True`: 强制 ZeroMQ 编译为动态库
- `sqlite3/*:shared=True`: 强制 SQLite3 编译为动态库

### 构建类型
- `-s build_type=Release`: Release 版本，优化编译
- `-s build_type=Debug`: Debug 版本，包含调试信息

### 依赖构建
- `--build=missing`: 当预编译包不可用时，从源码构建依赖

## 常见问题

### 1. 依赖包缺失
如果遇到依赖包缺失错误，使用 `--build=missing` 参数：
```bash
conan install . -of build_dir -s build_type=Release --build=missing
```

### 2. CMake 工具链文件未使用
确保正确指定 toolchain 文件路径：
```bash
cmake -S . -B build_dir -DCMAKE_TOOLCHAIN_FILE="build_dir/conan_toolchain.cmake"
```

### 3. 链接错误
如果出现链接错误，检查：
- 依赖库是否正确安装
- toolchain 文件是否正确生成
- 构建类型是否匹配